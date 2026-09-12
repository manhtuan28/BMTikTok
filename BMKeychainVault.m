//
//  BMKeychainVault.m
//  BMTikTok
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMKeychainVault.h"

static NSMutableDictionary<NSString *, NSDictionary *> *gVaultCache = nil;
static NSLock *gVaultLock = nil;

@implementation BMKeychainVault

+ (void)initialize {
    if (self == [BMKeychainVault class]) {
        gVaultLock = [[NSLock alloc] init];
        [self loadVaultFromFile];
    }
}

+ (NSString *)vaultFilePath {
    NSString *appSupport = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:appSupport]) {
        [fm createDirectoryAtPath:appSupport withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [appSupport stringByAppendingPathComponent:@".bmtiktok_keychain_vault.plist"];
}

+ (void)loadVaultFromFile {
    [gVaultLock lock];
    if (!gVaultCache) {
        NSString *path = [self vaultFilePath];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            gVaultCache = [dict mutableCopy];
        } else {
            gVaultCache = [NSMutableDictionary dictionary];
        }
    }
    [gVaultLock unlock];
}

+ (void)persistVaultToFile {
    NSString *path = [self vaultFilePath];
    if (gVaultCache) {
        NSDictionary *copy = [gVaultCache copy];
        [copy writeToFile:path atomically:YES];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

+ (NSString *)keyForClass:(id)itemClass service:(NSString *)service account:(NSString *)account {
    return [NSString stringWithFormat:@"%@###%@###%@", 
            itemClass ? [itemClass description] : @"",
            service ?: @"",
            account ?: @""];
}

+ (void)saveItemWithClass:(id)itemClass
                  service:(NSString *)service
                  account:(NSString *)account
                     data:(NSData *)data
               attributes:(NSDictionary *)attributes {
    if (!data) return;
    
    [gVaultLock lock];
    if (!gVaultCache) {
        gVaultCache = [NSMutableDictionary dictionary];
    }
    
    NSString *key = [self keyForClass:itemClass service:service account:account];
    
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    entry[@"data"] = data;
    if (service) entry[@"service"] = service;
    if (account) entry[@"account"] = account;
    if (itemClass) entry[@"class"] = [itemClass description];
    
    if (attributes) {
        NSMutableDictionary *cleanAttrs = [NSMutableDictionary dictionary];
        for (id k in attributes) {
            id v = attributes[k];
            // Chỉ lưu các kiểu dữ liệu tương thích property list
            if ([v isKindOfClass:[NSString class]] || 
                [v isKindOfClass:[NSNumber class]] || 
                [v isKindOfClass:[NSDate class]] || 
                [v isKindOfClass:[NSData class]]) {
                cleanAttrs[[k description]] = v;
            }
        }
        entry[@"attributes"] = cleanAttrs;
    }
    
    gVaultCache[key] = entry;
    [self persistVaultToFile];
    [gVaultLock unlock];
}

+ (NSData *)dataForClass:(id)itemClass
                 service:(NSString *)service
                 account:(NSString *)account {
    [gVaultLock lock];
    if (!gVaultCache) {
        [gVaultLock unlock];
        return nil;
    }
    
    // 1. Thử tìm chính xác bằng composite key
    NSString *exactKey = [self keyForClass:itemClass service:service account:account];
    NSDictionary *entry = gVaultCache[exactKey];
    if (entry && entry[@"data"]) {
        NSData *d = entry[@"data"];
        [gVaultLock unlock];
        return d;
    }
    
    // 2. Tìm kiếm linh hoạt theo service và account
    for (NSString *k in gVaultCache) {
        NSDictionary *item = gVaultCache[k];
        BOOL serviceMatch = YES;
        if (service && service.length > 0) {
            serviceMatch = [item[@"service"] isEqualToString:service];
        }
        
        BOOL accountMatch = YES;
        if (account && account.length > 0) {
            accountMatch = [item[@"account"] isEqualToString:account];
        }
        
        if (serviceMatch && accountMatch && item[@"data"]) {
            NSData *d = item[@"data"];
            [gVaultLock unlock];
            return d;
        }
    }
    
    // 3. Nếu chỉ có service mà không có account, tìm phần tử khớp service đầu tiên
    if (service && service.length > 0) {
        for (NSString *k in gVaultCache) {
            NSDictionary *item = gVaultCache[k];
            if ([item[@"service"] isEqualToString:service] && item[@"data"]) {
                NSData *d = item[@"data"];
                [gVaultLock unlock];
                return d;
            }
        }
    }
    
    [gVaultLock unlock];
    return nil;
}

+ (NSDictionary *)attributesForClass:(id)itemClass
                             service:(NSString *)service
                             account:(NSString *)account {
    [gVaultLock lock];
    if (!gVaultCache) {
        [gVaultLock unlock];
        return nil;
    }
    
    NSString *exactKey = [self keyForClass:itemClass service:service account:account];
    NSDictionary *entry = gVaultCache[exactKey];
    if (entry && entry[@"attributes"]) {
        NSDictionary *attrs = entry[@"attributes"];
        [gVaultLock unlock];
        return attrs;
    }
    
    for (NSString *k in gVaultCache) {
        NSDictionary *item = gVaultCache[k];
        BOOL serviceMatch = YES;
        if (service && service.length > 0) {
            serviceMatch = [item[@"service"] isEqualToString:service];
        }
        BOOL accountMatch = YES;
        if (account && account.length > 0) {
            accountMatch = [item[@"account"] isEqualToString:account];
        }
        if (serviceMatch && accountMatch && item[@"attributes"]) {
            NSDictionary *attrs = item[@"attributes"];
            [gVaultLock unlock];
            return attrs;
        }
    }
    
    [gVaultLock unlock];
    return nil;
}

+ (void)deleteItemsForClass:(id)itemClass
                    service:(NSString *)service
                    account:(NSString *)account {
    [gVaultLock lock];
    if (!gVaultCache) {
        [gVaultLock unlock];
        return;
    }
    
    NSMutableArray *keysToRemove = [NSMutableArray array];
    for (NSString *k in gVaultCache) {
        NSDictionary *item = gVaultCache[k];
        BOOL serviceMatch = YES;
        if (service && service.length > 0) {
            serviceMatch = [item[@"service"] isEqualToString:service];
        }
        BOOL accountMatch = YES;
        if (account && account.length > 0) {
            accountMatch = [item[@"account"] isEqualToString:account];
        }
        if (serviceMatch && accountMatch) {
            [keysToRemove addObject:k];
        }
    }
    
    if (keysToRemove.count > 0) {
        [gVaultCache removeObjectsForKeys:keysToRemove];
        [self persistVaultToFile];
    }
    [gVaultLock unlock];
}

+ (BOOL)hasItemForService:(NSString *)service {
    if (!service || service.length == 0) return NO;
    [gVaultLock lock];
    BOOL exists = NO;
    for (NSString *k in gVaultCache) {
        NSDictionary *item = gVaultCache[k];
        if ([item[@"service"] isEqualToString:service]) {
            exists = YES;
            break;
        }
    }
    [gVaultLock unlock];
    return exists;
}

@end
