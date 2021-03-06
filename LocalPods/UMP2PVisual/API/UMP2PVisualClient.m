//
//  UMP2PVisualClient
//  UMP2PVisual
//
//  Created by Fred on 2019/3/15.
//

#import "UMP2PVisualClient.h"

@interface ClientModel : NSObject
@property (nonatomic, strong) id    obj;
@property (nonatomic, assign) int   index;
@property (nonatomic, assign) int   type;
@property (nonatomic, assign) BOOL  isBackplay;
@end
@implementation ClientModel

@end

@interface UMP2PVisualClient()
@property (nonatomic, assign) int displayIndex;
/// 设备client数组
@property (nonatomic, strong) NSMutableArray *deviceClients;
/// 设备连接参数数组
@property (nonatomic, strong) NSMutableArray *deviceConnDatas;
/// 设备回放数据数组
@property (nonatomic, strong) NSMutableArray *deviceRecDatas;
@end
@implementation UMP2PVisualClient

- (instancetype)init{
    self = [super init];
    if (self) {
        self.displayIndex = 0;
    }
    return self;
}

#pragma mark 开始播放 实时预览/远程回放/本地Mp4文件
- (void)start:(UMDataTask)task index:(int)aIndex{
    // 播放client模型
    ClientModel *playModel = [self clientModelAtIndex:aIndex];
    // 播放连接数据模型
    ClientModel *connModel = [self deviceConnDataAtIndex:aIndex];
    // SDK播放client
    HKSDeviceClient *client = playModel.obj;
    if (client.playerState == HKS_NPC_D_MON_DEV_PLAY_STATUS_PLAYING) {
        // 当前为正在播放状态，返直接回播放成功
        task(UM_WEB_API_ERROR_ID_SUC, nil);
        return;
    }
    else if (client.playerState == HKS_NPC_D_MON_DEV_PLAY_STATUS_PAUSE) {
        // 当前为暂停状态
        if (connModel.type == HKS_NPC_D_MON_CLIENT_MODE_MP4) {
            // 本地MP4播放模式下，调用本地MP4的恢复播放接口
            [client resume];
            task(UM_WEB_API_ERROR_ID_SUC, nil);
        }else{
            // 远程回放播放模式下，调用远程回放的恢复播放接口
            [client controlRecord:HKS_NPC_D_MON_PLAY_CTRL_RESUME data:0];
            task(UM_WEB_API_ERROR_ID_SUC, nil);
        }
        return;
    }else if (client.playerState == HKS_NPC_D_MON_DEV_PLAY_STATUS_STOP
              || client.playerState == HKS_NPC_D_MON_DEV_PLAY_STATUS_READY) {
        // 当前为停止或者初始状态
        // 配置连接参数，就设置到client里面，如果没有提示播放失败
        if (connModel) {
            [client setDeviceConnParam:connModel.obj type:connModel.type];
        }else {
            task(UM_WEB_API_ERROR_ID_BAD_REQUEST, nil);
            return;
        }
        // 如果为回放模式，需要设置回放数据
        if (connModel.isBackplay) {
            ClientModel *recModel = [self deviceRecDataAtIndex:aIndex];
            if (recModel) {
                HKSRecFile *recFile = (HKSRecFile *)recModel.obj;
                [client setRecFileConnParam:recFile];
            }else{
                //缺少回放数据
                task(UM_WEB_API_ERROR_ID_BAD_REQUEST, nil);
                return;
            }
        }
    }
    // 开启声音
    client.audioEnabled = YES;
    // 关闭全屏显示模式，按比例播放
    client.fullScreenEnabled = NO;
    // 开始播放
    [client start:NO];
    task(UM_WEB_API_ERROR_ID_SUC, nil);
}

- (void)startOrStop:(UMDataTask)task index:(int)aIndex{
    // 播放client模型
    HKSDeviceClient *client = [self deviceClientAtIndex:aIndex];
    if (client.playerState == HKS_NPC_D_MON_DEV_PLAY_STATUS_STOP
        || client.playerState == HKS_NPC_D_MON_DEV_PLAY_STATUS_READY) {
        [self start:task index:aIndex];
    }else{
        [self stop:task index:aIndex];
    }
}

- (void)stop:(UMDataTask)task index:(int)aIndex{
    
    HKSDeviceClient *client = [self deviceClientAtIndex:aIndex];
    [client stop:NO exit:YES];
    task(UM_WEB_API_ERROR_ID_SUC, nil);
}

// 录像
- (void)record:(UMDataTask)task index:(int)aIndex param:(NSString *)param{
    HKSDeviceClient *client = [self deviceClientAtIndex:aIndex];
    if (client.playerState == HKS_NPC_D_MON_DEV_PLAY_STATUS_PLAYING) {
        if (client.recordEnabled) {
            [client stopLocalMP4REC:YES];
        }else{
            [client startRecordToPath:param];
        }
        task(UM_WEB_API_ERROR_ID_SUC, nil);
    }else{
        [client startRecordToPath:param];
        task(UM_WEB_API_ERROR_ID_CONN, nil);
    }
}
// 抓拍
- (void)capture:(UMDataTask)task index:(int)aIndex param:(NSString *)param{
    HKSDeviceClient *client = [self deviceClientAtIndex:aIndex];
    if (client.playerState == HKS_NPC_D_MON_DEV_PLAY_STATUS_PLAYING) {
        [client savePhotosToPath:param];
        task(UM_WEB_API_ERROR_ID_SUC, nil);
    }else{
        task(UM_WEB_API_ERROR_ID_CONN, nil);
    }
}

#pragma mark - Get/Set
#pragma mark 根据索引获取播放句柄
- (HKSDeviceClient *)deviceClientAtIndex:(int)aIndex{
    ClientModel *model = [self clientModelAtIndex:aIndex];
    return model.obj;
}

- (UIView *)displayView{
    return [self displayViewAtIndex:self.displayIndex];
}
- (UIView *)displayViewAtIndex:(int)aIndex{
    HKSDeviceClient *client = [self deviceClientAtIndex:aIndex];
    return client.view;
}

- (int)playStateAtIndex:(int)aIndex{
    HKSDeviceClient *client = [self deviceClientAtIndex:aIndex];
    return client.playerState;
}

#pragma mark 根据索引获取当前句柄所需连接参数数据
- (ClientModel *)deviceConnDataAtIndex:(int)aIndex{
    for (ClientModel *aModel in self.deviceConnDatas) {
        if (aModel.index == aIndex) {
            return aModel;
        }
    }
    return nil;
}

#pragma mark 根据索引获取当前句柄所需回放数据
- (ClientModel *)deviceRecDataAtIndex:(int)aIndex{
    for (ClientModel *aModel in self.deviceRecDatas) {
        if (aModel.index == aIndex) {
            return aModel;
        }
    }
    return nil;
}

#pragma mark 根据索引获取当前句柄所需连接参数Model
- (ClientModel *)clientModelAtIndex:(int)aIndex{
    for (ClientModel *aModel in self.deviceClients) {
        if (aModel.index == aIndex) {
            return aModel;
        }
    }
    ClientModel *model = [[ClientModel alloc] init];
    model.index = aIndex;
    model.obj = [[HKSDeviceClient alloc] init];
    [self.deviceClients addObject:model];
    return model;
}

#pragma mark 设置播放数据-实时预览
- (void)setupDeviceConnData:(TreeListItem *)aItem{
    [self setupDeviceConnData:aItem aIndex:self.displayIndex];
}
- (void)setupDeviceConnData:(TreeListItem *)aItem aIndex:(int)aIndex{
    ClientModel *model = nil;
    for (ClientModel *aModel in self.deviceConnDatas) {
        if (aModel.index == aIndex) {
            model = aModel;
            break;
        }
    }
    if (!model) {
        model = [[ClientModel alloc] init];
        model.index = aIndex;
        [self.deviceConnDatas addObject:model];
    }
    model.obj = aItem;
    model.type = HKS_NPC_D_MON_CLIENT_MODE_LOCALUMID;
    model.isBackplay = NO;
}

#pragma mark 设置播放数据-远程回放
- (void)setupDeviceRecData:(HKSRecFile *)aItem{
    [self setupDeviceRecData:aItem aIndex:self.displayIndex];
}
- (void)setupDeviceRecData:(HKSRecFile *)aItem aIndex:(int)aIndex{
    for (ClientModel *aModel in self.deviceRecDatas) {
        if (aModel.index == aIndex) {
            aModel.obj = aItem;
            return;
        }
    }
    ClientModel *model = [[ClientModel alloc] init];
    model.index = aIndex;
    model.obj = aItem;
    model.type = HKS_NPC_D_MON_CLIENT_MODE_LOCALUMID;
    [self.deviceRecDatas addObject:model];
    
    // 设置了回放数据，则当作该client为回放模式
    ClientModel *connModel = [self deviceConnDataAtIndex:aIndex];
    if (connModel) {
        connModel.isBackplay = YES;
    }
}

#pragma mark 设置播放数据-本地MP4文件
- (void)setupDeviceConnDataAtURL:(NSString *)param{
    [self setupDeviceConnDataAtURL:param aIndex:self.displayIndex];
}
- (void)setupDeviceConnDataAtURL:(NSString *)param aIndex:(int)aIndex{
    for (ClientModel *aModel in self.deviceConnDatas) {
        if (aModel.index == aIndex) {
            TreeListItem *item = aModel.obj;
            item.sDevId = param;
            return;
        }
    }
    ClientModel *model = [[ClientModel alloc] init];
    model.index = aIndex;
    TreeListItem *item = [[TreeListItem alloc] init];
    item.sDevId = param;
    model.obj = item;
    model.type = HKS_NPC_D_MON_CLIENT_MODE_MP4;
    [self.deviceConnDatas addObject:model];
}

#pragma mark 设备播放句柄列表
- (NSMutableArray *)deviceClients{
    if (!_deviceClients) {
        _deviceClients = [[NSMutableArray alloc] init];
    }
    return _deviceClients;
}
#pragma mark 设备连接数据列表
- (NSMutableArray *)deviceConnDatas{
    if (!_deviceConnDatas) {
        _deviceConnDatas = [[NSMutableArray alloc] init];
    }
    return _deviceConnDatas;
}

- (NSMutableArray *)deviceRecDatas{
    if (!_deviceRecDatas) {
        _deviceRecDatas = [[NSMutableArray alloc] init];
    }
    return _deviceRecDatas;
}

@end
