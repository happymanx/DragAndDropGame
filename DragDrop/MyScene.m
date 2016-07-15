//
//  MyScene.m
//  DragDrop
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 2;
static const uint32_t playerCategory         =  0x1 << 1;

@interface MyScene () 
 
@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSInteger monstersDestroyed;
@property (nonatomic) NSInteger monstersKept;
@property (nonatomic) NSInteger monstersMissed;
@property (nonatomic) NSInteger monstersCount;
@property (nonatomic) SKSpriteNode *button;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger second;
@property (nonatomic) SKLabelNode *timeNumberLabel;
@property (nonatomic) SKSpriteNode *timeNameLabel;
@property (nonatomic) SKSpriteNode *player;

@end

static NSString * const kAnimationName = @"movable";

@implementation MyScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;

        _background = [SKSpriteNode spriteNodeWithImageNamed:@"bg_game02.jpg"];
        _background.size = self.frame.size;
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        // 生成玩家
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"fairy_free_01.png"];
        self.player.name = kAnimationName;
        self.player.texture = [SKTexture textureWithImageNamed:@"fairy_free_01.png"];
        self.player.size = CGSizeMake(120, 120);
        self.player.physicsBody.dynamic = NO;
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
        self.player.physicsBody.categoryBitMask = playerCategory;
        self.player.physicsBody.contactTestBitMask = monsterCategory;
        self.player.physicsBody.collisionBitMask = monsterCategory;
        self.player.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        [self addChild:self.player];
        
        // 生成按鈕
        self.button = [self buttonNode];
        [self addChild:self.button];
        
        // 生成時間標題
        self.timeNameLabel = [self timeNameNode];
        [self addChild:self.timeNameLabel];
        // 生成時間數字
        self.timeNumberLabel = [self timeNumberNode];
        [self addChild:self.timeNumberLabel];

        // 生成計時器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        self.second = 100;
    }
 
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    
    // 點擊按鈕
    SKNode *node = [self nodeAtPoint:positionInScene];
    if ([node.name isEqualToString:@"button_pause02"]) {
        NSLog(@"press button");
        // 暫停遊戲
        self.button.texture = [SKTexture textureWithImageNamed:@"button_pause02_off.png"];
        self.scene.view.paused = YES;
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"請選擇動作" delegate:self cancelButtonTitle:@"繼續遊戲" otherButtonTitles:@"跳回首頁", nil];
        [av show];
    }
}

- (void)selectNodeForTouch:(CGPoint)touchLocation {
   //1
   SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
 
      //2
	if(![_selectedNode isEqual:touchedNode]) {
		[_selectedNode removeAllActions];
		[_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
 
		_selectedNode = touchedNode;
		//3
		if([[touchedNode name] isEqualToString:kAnimationName]) {
			SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-4.0f) duration:0.1],
													  [SKAction rotateByAngle:0.0 duration:0.1],
													  [SKAction rotateByAngle:degToRad(4.0f) duration:0.1]]];
			[_selectedNode runAction:[SKAction repeatActionForever:sequence]];
		}
	}
 
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

- (void)addMonster {
    
    self.monstersCount++;
    // Create sprite
    SKSpriteNode *monster;
    switch (self.monstersCount%6) {
        case 0:
            monster = [SKSpriteNode spriteNodeWithImageNamed:@"image_trash01"];
            break;
        case 1:
            monster = [SKSpriteNode spriteNodeWithImageNamed:@"image_trash02"];
            break;
        case 2:
            monster = [SKSpriteNode spriteNodeWithImageNamed:@"image_trash03"];
            break;
        case 3:
            monster = [SKSpriteNode spriteNodeWithImageNamed:@"image_trash04"];
            break;
        case 4:
            monster = [SKSpriteNode spriteNodeWithImageNamed:@"image_trash05"];
            break;
        case 5:
            monster = [SKSpriteNode spriteNodeWithImageNamed:@"image_trash06"];
            break;
        default:
            break;
    }
    monster.name = kAnimationName;
    monster.size = CGSizeMake(60, 60);
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size]; // 1
    monster.physicsBody.dynamic = YES; // 2
    monster.physicsBody.categoryBitMask = monsterCategory; // 3
    monster.physicsBody.contactTestBitMask = projectileCategory; // 4
    monster.physicsBody.collisionBitMask = playerCategory; // 5
    
    int minX = 0 + monster.size.width / 2;
    int maxX = self.frame.size.width + monster.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    int minY = 0 + monster.size.height / 2;
    int maxY = self.frame.size.height + monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    monster.position = CGPointMake(actualX, actualY);
    [self addChild:monster];
}

float degToRad(float degree) {
	return degree / 180.0f * M_PI;
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = self.size;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -[_background size].width+ winSize.width);
    retval.y = [self position].y;
    return retval;
}
 
- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = [_selectedNode position];
    if([[_selectedNode name] isEqualToString:kAnimationName]) {
        [_selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
    } else {
        CGPoint newPos = CGPointMake(position.x + translation.x, position.y + translation.y);
        [_background setPosition:[self boundLayerPos:newPos]];
    }
}

- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
}


//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//	UITouch *touch = [touches anyObject];
//	CGPoint positionInScene = [touch locationInNode:self];
//	CGPoint previousPosition = [touch previousLocationInNode:self];
// 
//	CGPoint translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y);
// 
//	[self panForTranslation:translation];
//}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
 
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
 
        touchLocation = [self convertPointFromView:touchLocation];
 
        [self selectNodeForTouch:touchLocation];
 
 
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
 
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
 
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
 
//        if (![[_selectedNode name] isEqualToString:kAnimalNodeName]) {
//            float scrollDuration = 0.2;
//            CGPoint velocity = [recognizer velocityInView:recognizer.view];
//            CGPoint pos = [_selectedNode position];
//            CGPoint p = mult(velocity, scrollDuration);
//       
//            CGPoint newPos = CGPointMake(pos.x + p.x, pos.y + p.y);
//            newPos = [self boundLayerPos:newPos];
//            [_selectedNode removeAllActions];
//       
//            SKAction *moveTo = [SKAction moveTo:newPos duration:scrollDuration];
//            [moveTo setTimingMode:SKActionTimingEaseOut];
//            [_selectedNode runAction:moveTo];
//        }
 
    }
}

CGPoint mult(const CGPoint v, const CGFloat s) {
	return CGPointMake(v.x*s, v.y*s);
}

- (SKSpriteNode *)buttonNode
{
    SKSpriteNode *buttonNode = [SKSpriteNode spriteNodeWithImageNamed:@"button_pause02_on.png"];
    buttonNode.size = CGSizeMake(64, 64);
    buttonNode.texture = [SKTexture textureWithImageNamed:@"button_pause02_on.png"];
    buttonNode.position = CGPointMake(62,self.frame.size.height-buttonNode.size.height/3*2);
    buttonNode.name = @"button_pause02";
    buttonNode.zPosition = 1.0;
    return buttonNode;
}

- (SKSpriteNode *)timeNameNode
{
    SKSpriteNode *timeNameNode = [SKSpriteNode spriteNodeWithImageNamed:@"word_time_blue.png"];
    timeNameNode.size = CGSizeMake(100, 32);
    timeNameNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-30);
    timeNameNode.name = @"word_time_blue";
    timeNameNode.zPosition = 1.0;
    return timeNameNode;
}

- (SKLabelNode *)timeNumberNode
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.zPosition = 0.5;
    label.text = @"0";
    label.fontSize = 20;
    label.fontColor = [SKColor colorWithRed:1 green:255.0/255 blue:255.0/255 alpha:1];
    label.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-70);
    return label;
}

-(void)updateTime:(NSTimer *)timer
{
    self.second--;
    if (self.second >= 0) {
        self.timeNumberLabel.text = [@(self.second) description];
    }
    else {
        self.second = 0;
    }
    
    // 更換精靈圖
    if (self.second % 2 == 1) {
        self.player.texture = [SKTexture textureWithImageNamed:@"fairy_free_01.png"];
    }
    else {
        self.player.texture = [SKTexture textureWithImageNamed:@"fairy_free_02.png"];
    }
    
    NSLog(@"second: %li", (long)self.second);
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {// 繼續遊戲
        self.scene.view.paused = NO;
        self.button.texture = [SKTexture textureWithImageNamed:@"button_pause02_on.png"];
    }
    if (buttonIndex == 1) {// 跳回首頁
        [self.timer invalidate];
//        [[AppDelegate sharedAppDelegate].mainVC.sceneVC backAction];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
//        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
    
    // 小精靈與鬼相撞
    if ((firstBody.categoryBitMask & playerCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        self.monstersKept++;
        [self player:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
}

- (void)player:(SKSpriteNode *)player didCollideWithMonster:(SKSpriteNode *)monster {
    [monster removeFromParent];
}

@end
