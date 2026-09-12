//
//  BMLogger.m
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMLogger.h"
#import <sys/utsname.h>
#import <os/log.h>

static NSFileHandle *gLogFileHandle = nil;
static NSLock *gLogLock = nil;
static dispatch_queue_t gLogQueue = nil;
static NSDateFormatter *gDateFormatter = nil;

@implementation BMLogger

+ (void)initialize {
    if (self == [BMLogger class]) {
        gLogLock = [[NSLock alloc] init];
        gLogQueue = dispatch_queue_create("com.bmtiktok.logger.queue", DISPATCH_QUEUE_SERIAL);
        gDateFormatter = [[NSDateFormatter alloc] init];
        [gDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
}

+ (NSString *)logFilePath {
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [docs stringByAppendingPathComponent:@"BMTikTok_Debug_Log.txt"];
}

+ (void)startLogging {
    [gLogLock lock];
    NSString *path = [self logFilePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        [fm createFileAtPath:path contents:nil attributes:nil];
    }
    
    gLogFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    [gLogFileHandle seekToEndOfFile];
    
    // Ghi tiêu đề phiên làm việc
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *header = [NSString stringWithFormat:
        @"\n================================================================\n"
        @"[BMTikTok Debug Session Started]\n"
        @"Time: %@\n"
        @"Device: %@ | iOS: %@\n"
        @"Bundle ID: %@ | App Version: %@\n"
        @"Log File: %@\n"
        @"================================================================\n\n",
        [gDateFormatter stringFromDate:[NSDate date]],
        deviceModel, sysVersion, bundleID, appVersion, path
    ];
    
    NSData *headerData = [header dataUsingEncoding:NSUTF8StringEncoding];
    [gLogFileHandle writeData:headerData];
    [gLogLock unlock];
    
    [self log:@"[INIT] BMLogger đã khởi động thành công. File log: %@", path];
    
    // Đăng ký nhận thông báo mạng từ ByteDance TTNetworkManager & FLEX
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleFLEXNetworkTransaction:)
                                                     name:@"FLEXNetworkRecorderTransactionUpdatedNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTTNetworkFinishNotification:)
                                                     name:@"kTTNetworkManagerMonitorFinishNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTTNetworkStartNotification:)
                                                     name:@"kTTNetworkManagerMonitorStartNotification"
                                                   object:nil];
    });
}

+ (void)handleTTNetworkStartNotification:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (![userInfo isKindOfClass:[NSDictionary class]]) return;
    id request = userInfo[@"kTTNetworkManagerMonitorRequestKey"];
    if (!request) return;
    
    NSString *url = nil;
    NSString *method = nil;
    @try {
        if ([request respondsToSelector:@selector(URL)]) {
            url = [[request performSelector:@selector(URL)] absoluteString];
        } else if ([request valueForKey:@"URL"]) {
            url = [[request valueForKey:@"URL"] absoluteString];
        }
        if ([request respondsToSelector:@selector(HTTPMethod)]) {
            method = [request performSelector:@selector(HTTPMethod)];
        } else if ([request valueForKey:@"HTTPMethod"]) {
            method = [request valueForKey:@"HTTPMethod"];
        }
    } @catch (NSException *e) {}
    
    if (url) {
        NSString *lower = [url lowercaseString];
        if ([lower containsString:@"passport"] || [lower containsString:@"login"] || [lower containsString:@"auth"] || [lower containsString:@"device_register"]) {
            [self log:@"[TTNET-START] %@ %@", method ?: @"POST", url];
        }
    }
}

+ (void)handleTTNetworkFinishNotification:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (![userInfo isKindOfClass:[NSDictionary class]]) return;
    
    id request = userInfo[@"kTTNetworkManagerMonitorRequestKey"];
    id response = userInfo[@"kTTNetworkManagerMonitorResponseKey"];
    id responseData = userInfo[@"kTTNetworkManagerMonitorResponseDataKey"];
    id error = userInfo[@"kTTNetworkManagerMonitorErrorKey"];
    
    NSString *url = nil;
    NSString *method = nil;
    NSDictionary *headers = nil;
    id body = nil;
    
    if (request) {
        @try {
            if ([request respondsToSelector:@selector(URL)]) {
                url = [[request performSelector:@selector(URL)] absoluteString];
            } else if ([request valueForKey:@"URL"]) {
                url = [[request valueForKey:@"URL"] absoluteString];
            }
            if ([request respondsToSelector:@selector(HTTPMethod)]) {
                method = [request performSelector:@selector(HTTPMethod)];
            } else if ([request valueForKey:@"HTTPMethod"]) {
                method = [request valueForKey:@"HTTPMethod"];
            }
            if ([request respondsToSelector:@selector(allHTTPHeaderFields)]) {
                headers = [request performSelector:@selector(allHTTPHeaderFields)];
            }
            if ([request respondsToSelector:@selector(HTTPBody)]) {
                body = [request performSelector:@selector(HTTPBody)];
            }
        } @catch (NSException *e) {}
    }
    
    NSInteger statusCode = 0;
    if (response) {
        @try {
            if ([response respondsToSelector:@selector(statusCode)]) {
                statusCode = (NSInteger)[response performSelector:@selector(statusCode)];
            }
        } @catch (NSException *e) {}
    }
    
    if (!url) url = [NSString stringWithFormat:@"%@", request ?: @"unknown_request"];
    
    NSString *lowerURL = [url lowercaseString];
    BOOL isCritical = [lowerURL containsString:@"passport"] ||
                      [lowerURL containsString:@"login"] ||
                      [lowerURL containsString:@"auth"] ||
                      [lowerURL containsString:@"token"] ||
                      [lowerURL containsString:@"code"] ||
                      [lowerURL containsString:@"device_register"] ||
                      [lowerURL containsString:@"risk"] ||
                      [lowerURL containsString:@"user/info"] ||
                      [lowerURL containsString:@"sec_uid"] ||
                      [lowerURL containsString:@"app_log"];
                      
    if (isCritical || statusCode >= 400 || error) {
        [self logNetworkURL:url
                     method:method ?: @"POST"
                    headers:headers
                     params:body
                 statusCode:statusCode
               responseBody:responseData
                      error:error];
    }
}

+ (void)handleFLEXNetworkTransaction:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    id transaction = userInfo[@"transaction"];
    if (!transaction) return;
    
    NSURLRequest *req = nil;
    NSURLResponse *resp = nil;
    NSError *error = nil;
    
    @try {
        req = [transaction valueForKey:@"request"];
        resp = [transaction valueForKey:@"response"];
        error = [transaction valueForKey:@"error"];
    } @catch (NSException *e) {}
    
    if (!req) return;
    
    NSString *url = req.URL.absoluteString;
    if (!url) return;
    
    NSString *method = req.HTTPMethod ?: @"GET";
    NSInteger statusCode = 0;
    if ([resp isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = [(NSHTTPURLResponse *)resp statusCode];
    }
    
    NSString *lowerURL = [url lowercaseString];
    BOOL isCritical = [lowerURL containsString:@"passport"] ||
                      [lowerURL containsString:@"login"] ||
                      [lowerURL containsString:@"auth"] ||
                      [lowerURL containsString:@"device_register"] ||
                      [lowerURL containsString:@"app_log"] ||
                      [lowerURL containsString:@"token"] ||
                      [lowerURL containsString:@"captcha"] ||
                      [lowerURL containsString:@"risk"] ||
                      [lowerURL containsString:@"sec_uid"] ||
                      [lowerURL containsString:@"user/info"];
    
    if (isCritical || statusCode >= 400 || error) {
        NSData *bodyData = nil;
        Class recorderClass = NSClassFromString(@"FLEXNetworkRecorder");
        if (recorderClass) {
            @try {
                id recorder = [recorderClass performSelector:NSSelectorFromString(@"defaultRecorder")];
                if (recorder && [recorder respondsToSelector:NSSelectorFromString(@"cachedDataForTransaction:")]) {
                    bodyData = [recorder performSelector:NSSelectorFromString(@"cachedDataForTransaction:") withObject:transaction];
                }
            } @catch (NSException *e) {}
        }
        
        id postBody = req.HTTPBody ?: bodyData;
        [self logNetworkURL:url
                     method:method
                    headers:req.allHTTPHeaderFields
                     params:postBody
                 statusCode:statusCode
               responseBody:bodyData
                      error:error];
    }
}

+ (void)log:(NSString *)format, ... {
    if (!format) return;
    
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    os_log(OS_LOG_DEFAULT, "[BMTikTok] %{public}s", [msg UTF8String]);
    printf("[BMTikTok] %s\n", [msg UTF8String]);
    
    if (gLogQueue) {
        dispatch_async(gLogQueue, ^{
            NSString *timestamp = [gDateFormatter stringFromDate:[NSDate date]];
            NSString *logLine = [NSString stringWithFormat:@"[%@] %@\n", timestamp, msg];
            [gLogLock lock];
            if (gLogFileHandle) {
                NSData *data = [logLine dataUsingEncoding:NSUTF8StringEncoding];
                if (data) {
                    @try {
                        [gLogFileHandle writeData:data];
                    } @catch (NSException *e) {}
                }
            }
            [gLogLock unlock];
        });
    }
}

+ (void)logNetworkURL:(NSString *)url
               method:(NSString *)method
              headers:(NSDictionary *)headers
               params:(id)params
           statusCode:(NSInteger)code
         responseBody:(id)responseBody
                error:(NSError *)error {
    
    if (gLogQueue) {
        dispatch_async(gLogQueue, ^{
            NSMutableString *logText = [NSMutableString stringWithFormat:@"\n-------- [NETWORK TRANSACTION] --------\n%@ %@\n", method ?: @"GET", url ?: @"unknown"];
            [logText appendFormat:@"Status: %ld\n", (long)code];
            
            if (headers && headers.count > 0) {
                [logText appendString:@"Headers:\n"];
                [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [logText appendFormat:@"  %@: %@\n", key, obj];
                }];
            }
            
            if (params) {
                if ([params isKindOfClass:[NSData class]]) {
                    id jsonObj = [NSJSONSerialization JSONObjectWithData:(NSData *)params options:0 error:nil];
                    if (jsonObj) {
                        NSData *pretty = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *str = [[NSString alloc] initWithData:pretty encoding:NSUTF8StringEncoding];
                        [logText appendFormat:@"Request Body (JSON):\n%@\n", str];
                    } else {
                        NSString *str = [[NSString alloc] initWithData:(NSData *)params encoding:NSUTF8StringEncoding];
                        if (str.length > 1000) {
                            str = [str substringToIndex:1000];
                        }
                        [logText appendFormat:@"Request Body (Data):\n%@\n", str];
                    }
                } else if ([params isKindOfClass:[NSDictionary class]] || [params isKindOfClass:[NSArray class]]) {
                    @try {
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
                        if (jsonData) {
                            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            [logText appendFormat:@"Request Body:\n%@\n", jsonStr];
                        }
                    } @catch (NSException *e) {
                        [logText appendFormat:@"Request Body:\n%@\n", params];
                    }
                } else {
                    [logText appendFormat:@"Request Body:\n%@\n", params];
                }
            }
            
            if (error) {
                [logText appendFormat:@"Error: %@ (Domain: %@, Code: %ld)\n", [error localizedDescription], [error domain], (long)[error code]];
            }
            
            if (responseBody) {
                if ([responseBody isKindOfClass:[NSData class]]) {
                    id jsonObj = [NSJSONSerialization JSONObjectWithData:(NSData *)responseBody options:0 error:nil];
                    if (jsonObj) {
                        NSData *pretty = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *str = [[NSString alloc] initWithData:pretty encoding:NSUTF8StringEncoding];
                        [logText appendFormat:@"Response Body (JSON):\n%@\n", str];
                    } else {
                        NSString *str = [[NSString alloc] initWithData:(NSData *)responseBody encoding:NSUTF8StringEncoding];
                        if (str.length > 2000) {
                            str = [str substringToIndex:2000];
                        }
                        [logText appendFormat:@"Response Body (Raw):\n%@\n", str];
                    }
                } else {
                    [logText appendFormat:@"Response Body:\n%@\n", responseBody];
                }
            }
            [logText appendString:@"----------------------------------------\n"];
            
            [self log:@"%@", logText];
        });
    }
}

+ (NSString *)readLogContent {
    NSString *path = [self logFilePath];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] ?: @"";
}

+ (void)clearLog {
    [gLogLock lock];
    NSString *path = [self logFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    [gLogLock unlock];
    [self startLogging];
    [self log:@"[LOG] Đã xóa lịch sử log và khởi tạo file mới."];
}

+ (void)shareLogFromViewController:(UIViewController *)viewController sender:(id)sender {
    NSString *path = [self logFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Chưa có file log" message:@"Chưa tìm thấy tệp log debug nào." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [viewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && [sender isKindOfClass:[UIView class]]) {
        activityVC.popoverPresentationController.sourceView = (UIView *)sender;
        activityVC.popoverPresentationController.sourceRect = [(UIView *)sender bounds];
    }
    [viewController presentViewController:activityVC animated:YES completion:nil];
}

@end
