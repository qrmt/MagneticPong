//
//  GameScene.m
//  Pong
//
//  Created by Oskar Vuola on 26/11/16.
//  Copyright © 2016 blastly. All rights reserved.
//

#import "GameScene.h"

static const uint32_t wallCategory     =  0x1 << 0;
static const uint32_t ballCategory        =  0x1 << 1;


@implementation GameScene {
    SKShapeNode *_playerBer;
    SKShapeNode *_enemyBar;
    SKShapeNode *_ball;
    float _currentPosition;
    float _boardWidth;
    float _boardHeight;
    BOOL _flag;
}

- (void)didMoveToView:(SKView *)view {
    _currentPosition = 0;
    _flag = NO;
    
    float boardWidth = 50.0f;
    float boardHeight = 300.0f;
    float ballRadius = 20.0f;
    
    _boardWidth = boardWidth;
    _boardHeight = boardHeight;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = wallCategory;
    self.physicsWorld.contactDelegate = self;
    
    
    SKShapeNode *enemy_bar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(boardWidth, boardHeight) cornerRadius:0];
    enemy_bar.lineWidth = 2.5;

    enemy_bar.name = @"enemy_bar";
    enemy_bar.fillColor = [SKColor whiteColor];
    enemy_bar.position = CGPointMake(CGRectGetMinX(self.frame) + 0.5* boardWidth,0);
    enemy_bar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(boardWidth, boardHeight)];
    enemy_bar.physicsBody.affectedByGravity = NO;
    enemy_bar.physicsBody.allowsRotation = NO;
    enemy_bar.physicsBody.usesPreciseCollisionDetection = YES;
    _enemyBar = enemy_bar;
    
    [self addChild:enemy_bar];
    
    SKShapeNode *player_bar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(boardWidth, boardHeight) cornerRadius:0];
    player_bar.lineWidth = 2.5;
    
    player_bar.name = @"player_bar";
    player_bar.fillColor = [SKColor whiteColor];
    player_bar.position = CGPointMake(CGRectGetMaxX(self.frame) - 0.5 * boardWidth, 0);
    player_bar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(boardWidth, boardHeight)];
    player_bar.physicsBody.affectedByGravity = NO;
    player_bar.physicsBody.allowsRotation = NO;
    player_bar.physicsBody.usesPreciseCollisionDetection = YES;
    _playerBer = player_bar;
    
    [self addChild:player_bar];
    
    SKShapeNode *ball = [SKShapeNode shapeNodeWithCircleOfRadius:ballRadius];
    ball.lineWidth = 2.5;
    
    ball.name = @"ball";
    ball.fillColor = [SKColor whiteColor];
    ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ballRadius];
    ball.physicsBody.affectedByGravity = NO;
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.friction = 0.0;
    ball.physicsBody.linearDamping = 0.0f;
    ball.physicsBody.angularDamping = 0.0f;
    ball.physicsBody.restitution = 1.0f;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.usesPreciseCollisionDetection = YES;
    
    _ball = ball;
    
    [self addChild:ball];
    
    SKLabelNode *calibrationButton = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    
    calibrationButton.text = @"Calibrate";
    calibrationButton.fontSize = 55;
    calibrationButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMaxY(self.frame) - 100);
    calibrationButton.name = @"calibration";
    
    [self addChild:calibrationButton];
    
    SKLabelNode *resetButton = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    
    resetButton.text = @"Reset";
    resetButton.fontSize = 55;
    resetButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMinY(self.frame));
    resetButton.name = @"reset";
    
    [self addChild:resetButton];


}

- (void)reset {
    _flag = NO;
    _ball.physicsBody.velocity = CGVectorMake(0, 0);
    _ball.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        
        if ([node.name isEqualToString:@"calibration"]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"CalibrationNotification"
             object:nil];
        } else if ([node.name isEqualToString:@"reset"]) {
            [self reset];
        }
        
    }
}



- (void)updateBoardLocation:(float)location {
    _currentPosition = location;
}


-(void)update:(CFTimeInterval)currentTime {
    if (!_flag) {
        _flag = YES;
        [_ball.physicsBody applyImpulse:CGVectorMake(50, 50)];
    }
    float curpos = MAX(_currentPosition, 0) * 0.2;
    double position = ((double)8833.0 - sqrt(((double)2693200.0f)*curpos - (double)325958111)) / 13466.0f;
    float location = fabs(position) * CGRectGetMaxY(self.frame);
    NSLog(@"location = %f, position = %f", location, position);
    
    // Handle NaN
    if (location != location) {
        location = 0.0f;
    }
    
    float ypos = MIN(CGRectGetMinY(self.frame) + location + _boardHeight / 2, CGRectGetMaxY(self.frame) - 0.5 * _boardHeight);
    //NSLog(@"ypos = %f", ypos);
    // Called before each frame is rendered
    _playerBer.position = CGPointMake(CGRectGetMaxX(self.frame) - 0.5 * _boardWidth, ypos);
    
    float enemyPos;
    float posDiff = _ball.position.y - _enemyBar.position.y;
    float enemySpeed = 12;
    if (fabs(posDiff) < enemySpeed) {
        enemyPos = _ball.position.y;
    } else {
        int direction = signum2(posDiff);
        enemyPos = _enemyBar.position.y + direction*enemySpeed;
    }
    _enemyBar.position = CGPointMake(CGRectGetMinX(self.frame) + 0.5* _boardWidth, enemyPos);
    
    if (_ball.position.x + _ball.frame.size.width / 2 > _playerBer.position.x) {
        //NSLog(@"Hit the wall");
    }
}

- (void)updateYcoord:(float)y {
    //NSLog(@"Y: %f", y);
    [self updateBoardLocation:y];
}

int signum2(float n) { return (n < 0) ? -1 : (n > 0) ? +1 : 0; }


@end
