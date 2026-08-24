#import <Foundation/Foundation.h>

@protocol BMMultipleDownloadDelegate <NSObject>
- (void)downloaderProgress:(float)progress;
- (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths;
- (void)downloaderDidFailureWithError:(NSError *)error;
@end

@interface BMMultipleDownload : NSObject <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, weak) id<BMMultipleDownloadDelegate> delegate;
- (void)downloadFiles:(NSArray<NSURL *> *)fileURLs;

@end