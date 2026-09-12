//
//  BMLogger.h
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//  Hệ thống ghi log chuyên sâu phục vụ Debug và khắc phục lỗi Login Sideload
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BMLogger : NSObject

+ (void)startLogging;
+ (void)log:(NSString *)format, ...;
+ (void)logNetworkURL:(NSString *)url
               method:(NSString *)method
              headers:(NSDictionary *)headers
               params:(id)params
           statusCode:(NSInteger)code
         responseBody:(id)responseBody
                error:(NSError *)error;

+ (NSString *)logFilePath;
+ (NSString *)readLogContent;
+ (void)clearLog;
+ (void)shareLogFromViewController:(UIViewController *)viewController sender:(id)sender;

@end
