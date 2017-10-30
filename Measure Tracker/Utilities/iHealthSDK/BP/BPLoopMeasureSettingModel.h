//
//  BPLoopMeasureSettingModel.h
//  iHealthSDKStatic
//
//  Created by Realank on 2017/9/27.
//  Copyright © 2017年 ihealthSDK. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 ABPM loop remeasure method

 - BPLoopRemeasureNO: don't remeasure
 - BPLoopRemeasure90Sec: 90 seconds remeasure
 - BPLoopRemeasure90Sec10Min: 90 seconds and 10 minutes remeasure
 */
typedef NS_ENUM(NSUInteger, BPLoopRemeasureMethod) {
    BPLoopRemeasureNO = 0x00,
    BPLoopRemeasure90Sec = 0x01,
    BPLoopRemeasure90Sec10Min = 0x03,
};


/**
 ABPM loop measure time setting model
 */
@interface BPLoopMeasureTimeSetting : NSObject
@property (nonatomic, assign) NSUInteger hour;
@property (nonatomic, assign) NSUInteger min;
@property (nonatomic, assign) NSUInteger measureIntervalInMin;
@property (nonatomic, assign) BOOL viberateAlert;
@property (nonatomic, assign) BOOL soundAlert;

+ (instancetype) modelWithHour:(NSUInteger)hour
                           min:(NSUInteger)min
          measureIntervalInMin:(NSUInteger)measureIntervalInMin
                 viberateAlert:(BOOL)viberateAlert
                    soundAlert:(BOOL)soundAlert;

+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

@end


/**
 ABPM loop measure setting model
 */
@interface BPLoopMeasureSettingModel : NSObject

@property (nonatomic, assign) BOOL isTakeMedicine;
@property (nonatomic, assign) BPLoopRemeasureMethod remeasureMethod;
@property (nonatomic, assign) uint8_t measureHours;
@property (nonatomic, strong) BPLoopMeasureTimeSetting* morningTimeSetting;
@property (nonatomic, strong) BPLoopMeasureTimeSetting* nightTimeSetting;
@property (nonatomic, strong) BPLoopMeasureTimeSetting* noonSleepTimeSetting;
@property (nonatomic, strong) BPLoopMeasureTimeSetting* noonWakeupTimeSetting;

+ (instancetype)modelWithTakeMedicine:(BOOL)isTakeMedicine
                      remeasureMethod:(BPLoopRemeasureMethod)remeasureMethod
                         measureHours:(uint8_t)measureHours
                   morningTimeSetting:(BPLoopMeasureTimeSetting*)morningTimeSetting
                     nightTimeSetting:(BPLoopMeasureTimeSetting*)nightTimeSetting
                 noonSleepTimeSetting:(BPLoopMeasureTimeSetting*)noonSleepTimeSetting
                noonWakeupTimeSetting:(BPLoopMeasureTimeSetting*)noonWakeupTimeSetting;

+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));


@end


/**
 ABPM loop measure status

 - BPLoopMeasureStateNoScheme: don't have scheme
 - BPLoopMeasureStateSchemeUncompleted: scheme not completed
 - BPLoopMeasureStateSchemeCompleted: scheme has been completed
 */
typedef NS_ENUM(NSUInteger, BPLoopMeasureStatus) {
    BPLoopMeasureStateNoScheme,
    BPLoopMeasureStateSchemeUncompleted,
    BPLoopMeasureStateSchemeCompleted,
};



/**
 ABPM loop measure setting result model
 */
@interface BPLoopMeasureSettingResultModel : BPLoopMeasureSettingModel

@property (nonatomic, assign) BPLoopMeasureStatus loopMeasureStatus;
@property (nonatomic, strong) NSDate* realStartDate;
@property (nonatomic, assign) NSInteger realStartDateTimeZoneInMin;

+ (instancetype)modelWithLoopMeasureStatus:(BPLoopMeasureStatus)loopMeasureStatus
                                TakeMedicine:(BOOL)isTakeMedicine
                             remeasureMethod:(BPLoopRemeasureMethod)remeasureMethod
                                measureHours:(uint8_t)measureHours
                               realStartDate:(NSDate*)realStartDate
                  realStartDateTimeZoneInMin:(NSInteger)realStartDateTimeZoneInMin
                       morningTimeSetting:(BPLoopMeasureTimeSetting*)morningTimeSetting
                         nightTimeSetting:(BPLoopMeasureTimeSetting*)nightTimeSetting
                     noonSleepTimeSetting:(BPLoopMeasureTimeSetting*)noonSleepTimeSetting
                    noonWakeupTimeSetting:(BPLoopMeasureTimeSetting*)noonWakeupTimeSetting;

+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

@end
