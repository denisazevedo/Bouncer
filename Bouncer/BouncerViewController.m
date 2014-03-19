//
//  BouncerViewController.m
//  Bouncer
//
//  Created by Denis C de Azevedo on 14/03/14.
//  Copyright (c) 2014 Denis C de Azevedo. All rights reserved.
//

#import "BouncerViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface BouncerViewController ()
@property (nonatomic, strong) UIView *redBlock;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIGravityBehavior *gravity;
@property (nonatomic, weak) UICollisionBehavior *collider;
@property (nonatomic, weak) UIDynamicItemBehavior *elastic;
@property (nonatomic, strong) CMMotionManager *motionManager;
@end

@implementation BouncerViewController

static CGSize blockSize = { 40 , 40 };

- (UIView *)addBlockOffsetFromCenterBy:(UIOffset)offset {
    
    CGPoint blockCenter = CGPointMake(CGRectGetMidX(self.view.bounds) + offset.horizontal,
                                      CGRectGetMidY(self.view.bounds) + offset.vertical);
    
    CGRect blockFrame = CGRectMake(blockCenter.x - blockSize.width/2,
                                   blockCenter.y - blockSize.height/2,
                                   blockSize.width,
                                   blockSize.height);
    
    UIView *block = [[UIView alloc] initWithFrame:blockFrame];
    [self.view addSubview:block];
    return block;
}

- (UIDynamicAnimator *)animator {
    if (!_animator) _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    return _animator;
}

- (UICollisionBehavior *)collider {
    if (!_collider) {
        UICollisionBehavior *collider = [[UICollisionBehavior alloc] init];
        collider.translatesReferenceBoundsIntoBoundary = YES;
        [self.animator addBehavior:collider];
        self.collider = collider;
    }
    return _collider;
}

- (UIGravityBehavior *)gravity {
    if (!_gravity) {
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] init];
        [self.animator addBehavior:gravity];
        self.gravity = gravity;
    }
    return _gravity;
}

- (UIDynamicItemBehavior *)elastic {
    if (!_elastic) {
        UIDynamicItemBehavior *elastic = [[UIDynamicItemBehavior alloc] init];
        elastic.elasticity = 1.0;
        [self.animator addBehavior:elastic];
        self.elastic = elastic;
    }
    return _elastic;
}

- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.1; //10 per second
    }
    return _motionManager;
}

- (void)startGame {
    self.redBlock = [self addBlockOffsetFromCenterBy:UIOffsetMake(0, 0)];
    self.redBlock.backgroundColor = [UIColor redColor];
    
    [self.collider addItem:self.redBlock];
    [self.elastic addItem:self.redBlock];
    [self.gravity addItem:self.redBlock];
    
    self.gravity.gravityDirection = CGVectorMake(0, 0);
    
    if (!self.motionManager.isAccelerometerActive) {
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                 CGFloat x = accelerometerData.acceleration.x;
                 CGFloat y = accelerometerData.acceleration.y;
                 switch (self.interfaceOrientation) {
                     case UIInterfaceOrientationLandscapeRight:
                         self.gravity.gravityDirection = CGVectorMake(-y, -x); break;
                     case UIInterfaceOrientationLandscapeLeft:
                         self.gravity.gravityDirection = CGVectorMake(y, x); break;
                     case UIInterfaceOrientationPortrait:
                         self.gravity.gravityDirection = CGVectorMake(x, -y); break;
                     case UIInterfaceOrientationPortraitUpsideDown:
                         self.gravity.gravityDirection = CGVectorMake(-x, y); break;
                 }
             }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startGame];
}

@end
