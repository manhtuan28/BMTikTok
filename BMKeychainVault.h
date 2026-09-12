//
//  BMKeychainVault.h
//  BMTikTok
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//  Bộ nhớ Keychain dự phòng an toàn tuyệt đối cho ứng dụng Sideload (AltStore, Sideloadly, TrollStore, Esign).
//  Khắc phục triệt để lỗi -34018 (errSecMissingEntitlement) và -25299 (errSecDuplicateItem) gây lặp đăng nhập (Login Loop).
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface BMKeychainVault : NSObject

+ (void)saveItemWithClass:(id)itemClass
                  service:(NSString *)service
                  account:(NSString *)account
                     data:(NSData *)data
               attributes:(NSDictionary *)attributes;

+ (NSData *)dataForClass:(id)itemClass
                 service:(NSString *)service
                 account:(NSString *)account;

+ (NSDictionary *)attributesForClass:(id)itemClass
                             service:(NSString *)service
                             account:(NSString *)account;

+ (void)deleteItemsForClass:(id)itemClass
                    service:(NSString *)service
                    account:(NSString *)account;

+ (BOOL)hasItemForService:(NSString *)service;

@end
