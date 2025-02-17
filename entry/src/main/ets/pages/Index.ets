import { promptAction } from '@kit.ArkUI' // 导入ArkUI工具包中的提示操作模块
// 在 Index.ets 或其他页面文件中导入 AVPlayerManager
import { AVPlayerManager } from '../manager/AVPlayerManager';
// 在 Index.ets 或其他页面文件中导入 AVPlayerManager
import router from '@system.router';

@ObservedV2 // 观察者模式装饰器
class Cell { // 定义游戏中的单元格类
  @Trace // 跟踪装饰器，标记属性以被跟踪
  type: number = 0; // 单元格类型，0：透明，1：墙，2：可移动区域
  @Trace topLeft: number = 0; // 左上角圆角大小
  @Trace topRight: number = 0; // 右上角圆角大小
  @Trace bottomLeft: number = 0; // 左下角圆角大小
  @Trace bottomRight: number = 0; // 右下角圆角大小
  @Trace x: number = 0; // 单元格的X坐标偏移量
  @Trace y: number = 0; // 单元格的Y坐标偏移量
  constructor(cellType: number) { // 构造函数
    this.type = cellType; // 初始化单元格类型
  }
}
@ObservedV2 // 观察者模式装饰器
class MyPosition { // 定义位置类
  @Trace // 跟踪装饰器，标记属性以被跟踪
  x: number = 0; // X坐标
  @Trace y: number = 0; // Y坐标

  constructor(x: number = 0, y: number = 0) { // 构造函数，接受x和y两个参数
    this.x = x;
    this.y = y;
  }
  setPosition(x: number, y: number) { // 设置位置的方法
    this.x = x; // 更新X坐标
    this.y = y; // 更新Y坐标
  }
}

interface DirectionFrames {
  up: Resource[];
  down: Resource[];
  left:Resource[];
  right: Resource[];
}

interface IdleImages {
  up: Resource;
  down:Resource;
  left:Resource;
  right: Resource;
}


@Entry // 入口装饰器
@Component // 组件装饰器
struct Sokoban  { // 定义游戏主结构
  cellWidth: number = 80; // 单元格宽度
  @State grid: Cell[][] = [];// 游戏网格状态
  @State victoryPositions: MyPosition[] = [];// 胜利位置数组
  @State cratePositions: MyPosition[] = [];// 箱子位置数组
  @State playerImage: Resource = $r('app.media.Character4'); // 初始角色图片
playerPosition: MyPosition = new MyPosition(); // 玩家位置
  @State screenStartX: number = 0; // 触摸开始时的屏幕X坐标
  @State screenStartY: number = 0; // 触摸开始时的屏幕Y坐标
  @State lastScreenX: number = 0; // 触摸结束时的屏幕X坐标
  @State lastScreenY: number = 0; // 触摸结束时的屏幕Y坐标
  @State startTime: number = 0; // 游戏开始时间
  @State isAnimationRunning: boolean = false; // 动画是否正在运行
  @State moveDirection: string = ""; // 当前移动方向，用于切换图片
  @State historyPlayerPositions: MyPosition[] = []; // 玩家位置历史
  @State historyCratePositions: MyPosition[][] = []; // 存储箱子位置的数组的数组
  private avPlayerManager: AVPlayerManager = new AVPlayerManager();
  @State isMusicPlaying: boolean = false;
  @State level: number = 1; // 默认启动关卡1

  @State timeout: number = 30000; // 默认30秒
  @State timer: number | null = null; // 定时器引用
  @State countdown: number = 30; // 倒计时初始值，单位为秒
  @State countdownInterval: number | null = null; // 倒计时定时器引用
  aboutToAppear(): void {
    // 获取传递的关卡号
    let params = router.getParams();
    if (params && params.level) {
      this.level = Number(params.level); // 设置关卡号
    }
    this.initializeGame(this.level); // 初始化游戏并加载对应关卡地图
    this.avPlayerManager.playMusicByRawSrc('rawfile/bg.mp3');// 确保路径正确
  }

  playMusic(): void {
    this.avPlayerManager.continueMusic(); // 继续音乐播放
    this.isMusicPlaying = true;
  }

  pauseMusic(): void {
    this.avPlayerManager.stopMusic(); // 暂停音乐播放
    this.isMusicPlaying = false;
  }

  toggleMusic(): void {
    if (this.isMusicPlaying) {
      this.pauseMusic();
    } else {
      this.playMusic();
    }
  }

  gameOver(): void {
    clearInterval(this.countdownInterval); // 清除定时器
    clearTimeout(this.timer); // 清除定时器
    promptAction.showDialog({
      title: '游戏失败',
      message: '时间已到，未能完成游戏。',
      buttons: [{ text: '重新开始', color: '#ffa500' }]
    }).then(() => {
      this.initializeGame(this.level); // 重新开始当前关卡
    });
  }

  initializeGame(level: number): void {
    // 清除之前的定时器和倒计时状态
    if (this.timer) {
      clearTimeout(this.timer);
    }
    if (this.countdownInterval) {
      clearInterval(this.countdownInterval);
    }
    this.startTime = Date.now();
    this.timeout = level <= 2 ? 30000 : 60000; // 第1,2关30秒，第3,4,5关60秒
    this.timer = setTimeout(() => this.gameOver(), this.timeout); // 设置定时器
    this.countdown = this.timeout / 1000; // 将毫秒转换为秒
    this.countdownInterval = setInterval(() => {
      if (this.countdown > 0) {
        this.countdown--; // 每秒减少1
      } else {
        clearInterval(this.countdownInterval); // 清除定时器
        this.gameOver(); // 游戏失败
      }
    }, 1000);
    if (level === 4) {
      this.grid = [
        [new Cell(0), new Cell(1), new Cell(1), new Cell(1), new Cell(1), new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(1), new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2), new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(1)],
        [new Cell(0), new Cell(1), new Cell(1), new Cell(1), new Cell(1), new Cell(1)],
      ];
      this.victoryPositions = [new MyPosition(), new MyPosition()];
      this.cratePositions = [new MyPosition(), new MyPosition()];
      this.victoryPositions[0].setPosition(1, 3);
      this.victoryPositions[1].setPosition(1, 4);
      this.cratePositions[0].setPosition(2, 2);
      this.cratePositions[1].setPosition(2, 3);
      this.playerPosition.setPosition(1, 2);
      this.playerImage = $r('app.media.Character4'); // 初始图片
    } else if (level === 5) {
      this.grid = [
        [new Cell(0), new Cell(0), new Cell(0), new Cell(1), new Cell(1), new Cell(1), new Cell(1), new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(1), new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(1), new Cell(1), new Cell(2), new Cell(2), new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2), new Cell(2), new Cell(2), new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(2), new Cell(1), new Cell(1), new Cell(2), new Cell(2), new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(1), new Cell(2), new Cell(1)],
        [new Cell(0), new Cell(1), new Cell(1), new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(1)],
        [new Cell(0), new Cell(0), new Cell(0), new Cell(1), new Cell(1), new Cell(1), new Cell(1), new Cell(1)],
      ];
      this.victoryPositions = [new MyPosition(), new MyPosition(), new MyPosition()];
      this.cratePositions = [new MyPosition(), new MyPosition(), new MyPosition()];
      // 胜利位置
      this.victoryPositions[0].setPosition(1, 4); // 左上
      this.victoryPositions[1].setPosition(1, 5); // 右上
      this.victoryPositions[2].setPosition(4, 6); // 中间靠下
      // 箱子位置
      this.cratePositions[0].setPosition(2, 5); // 可推向胜利位置 (1, 1)
      this.cratePositions[1].setPosition(3, 2); // 可推向胜利位置 (1, 5)
      this.cratePositions[2].setPosition(5, 6); // 可推向胜利位置 (4, 3)
      // 玩家初始位置
      this.playerPosition.setPosition(2, 2);
      this.playerImage = $r('app.media.Character4'); // 初始图片
    }
    else if (level ===1 ) {
      this.grid = [
        [new Cell(1), new Cell(1), new Cell(1), new Cell(1), new Cell(1),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(1), new Cell(1), new Cell(1),  new Cell(1)],
      ];
      this.victoryPositions = [new MyPosition(), new MyPosition(), new MyPosition(),new MyPosition(),new MyPosition()];
      this.cratePositions = [new MyPosition(), new MyPosition(), new MyPosition(),new MyPosition(),new MyPosition()];
      // 胜利位置
      this.victoryPositions[0].setPosition(2, 3); // 左上
      this.victoryPositions[1].setPosition(3, 3); // 右上
      this.victoryPositions[2].setPosition(4, 3); // 中间靠下
      this.victoryPositions[3].setPosition(5, 3); // 中间靠下
      this.victoryPositions[4].setPosition(5, 2); // 中间靠下
      // 箱子位置
      this.cratePositions[0].setPosition(2, 2); // 可推向胜利位置 (1, 1)
      this.cratePositions[1].setPosition(3, 2); // 可推向胜利位置 (1, 5)
      this.cratePositions[2].setPosition(4, 2); // 可推向胜利位置 (4, 3)
      this.cratePositions[3].setPosition(5, 2); // 可推向胜利位置 (4, 3)
      this.cratePositions[4].setPosition(2, 3); // 可推向胜利位置 (4, 3)
      // 玩家初始位置
      this.playerPosition.setPosition(1, 1);
      this.playerImage = $r('app.media.Character4'); // 初始图片
    }
    else if (level ===2 ) {
      this.grid = [
        [new Cell(0), new Cell(0), new Cell(0), new Cell(1), new Cell(1),  new Cell(1),  new Cell(0)],
        [new Cell(0), new Cell(1), new Cell(1), new Cell(1), new Cell(2),  new Cell(1),  new Cell(0)],
        [new Cell(0), new Cell(1), new Cell(2), new Cell(2), new Cell(2),  new Cell(1),  new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(1), new Cell(2), new Cell(2),  new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2), new Cell(1),  new Cell(1),  new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(2), new Cell(2), new Cell(1),  new Cell(0),  new Cell(0)],
        [new Cell(0), new Cell(1), new Cell(2), new Cell(1), new Cell(1),  new Cell(0),  new Cell(0)],
        [new Cell(0), new Cell(1), new Cell(1), new Cell(1), new Cell(0),  new Cell(0),  new Cell(0)],
      ];
      this.victoryPositions = [new MyPosition(), new MyPosition(), new MyPosition(),new MyPosition(),new MyPosition(),new MyPosition()];
      this.cratePositions = [new MyPosition(), new MyPosition(), new MyPosition(),new MyPosition(),new MyPosition(),new MyPosition()];
      // 胜利位置
      this.victoryPositions[0].setPosition(1, 4); // 左上
      this.victoryPositions[1].setPosition(2, 2); // 右上
      this.victoryPositions[2].setPosition(3, 5); // 中间靠下
      this.victoryPositions[3].setPosition(4, 1); // 中间靠下
      this.victoryPositions[4].setPosition(6, 2); // 中间靠下
      this.victoryPositions[5].setPosition(5, 3); // 中间靠下
      // 箱子位置
      this.cratePositions[0].setPosition(2, 3); // 可推向胜利位置 (1, 1)
      this.cratePositions[1].setPosition(2, 4); // 可推向胜利位置 (1, 5)
      this.cratePositions[2].setPosition(3, 4); // 可推向胜利位置 (4, 3)
      this.cratePositions[3].setPosition(4, 2); // 可推向胜利位置 (4, 3)
      this.cratePositions[4].setPosition(5, 2); // 可推向胜利位置 (4, 3)
      this.cratePositions[5].setPosition(5, 3); // 可推向胜利位置 (4, 3)
      // 玩家初始位置
      this.playerPosition.setPosition(3, 3);
      this.playerImage = $r('app.media.Character4'); // 初始图片
    }
    else if (level === 3) {
      this.grid = [
        [new Cell(1), new Cell(1), new Cell(1), new Cell(1),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(2), new Cell(2), new Cell(2),  new Cell(1)],
        [new Cell(1), new Cell(1), new Cell(1), new Cell(1),  new Cell(1)],
      ];
      this.victoryPositions = [new MyPosition(), new MyPosition(), new MyPosition()];
      this.cratePositions = [new MyPosition(), new MyPosition(), new MyPosition()];
      // 胜利位置
      this.victoryPositions[0].setPosition(1, 1); // 左上
      this.victoryPositions[1].setPosition(2, 1); // 右上
      this.victoryPositions[2].setPosition(4, 3); // 中间靠下
      // 箱子位置
      this.cratePositions[0].setPosition(2, 2); // 可推向胜利位置 (1, 1)
      this.cratePositions[1].setPosition(3, 2); // 可推向胜利位置 (1, 5)
      this.cratePositions[2].setPosition(4, 2); // 可推向胜利位置 (4, 3)
      // 玩家初始位置
      this.playerPosition.setPosition(1, 3);
      this.playerImage = $r('app.media.Character4'); // 初始图片
    }
  }
  updatePlayerImage(): void {
    const directionFrames: DirectionFrames = {
      up: [$r('app.media.Character8'), $r('app.media.Character9')],
      down: [$r('app.media.Character5'), $r('app.media.Character6')],
      left: [$r('app.media.Character10')],
      right: [$r('app.media.Character3')],
    };

    // 动态切换行走图片
    if (this.moveDirection === "up") {
      this.playerImage = this.playerImage === directionFrames.up[0] ? directionFrames.up[1] : directionFrames.up[0];
    } else if (this.moveDirection === "down") {
      this.playerImage = this.playerImage === directionFrames.down[0] ? directionFrames.down[1] : directionFrames.down[0];
    } else if (this.moveDirection === "left") {
      this.playerImage = directionFrames.left[0];
    } else if (this.moveDirection === "right") {
      this.playerImage = directionFrames.right[0];
    }
  }


  stopPlayerAnimation(): void {
    // 静止时切换为静止图片
    const idleImages: IdleImages ={
      up: $r('app.media.Character7'),
      down: $r('app.media.Character4'),
      left: $r('app.media.Character1'),
      right: $r('app.media.Character2'),
    };
    // 检查 moveDirection 是否是预定义的方向之一
    if (this.moveDirection === "up") {
      this.playerImage = idleImages.up;
    } else if (this.moveDirection === "down") {
      this.playerImage = idleImages.down;
    } else if (this.moveDirection === "left") {
      this.playerImage = idleImages.left;
    } else if (this.moveDirection === "right") {
      this.playerImage = idleImages.right;
    }

    this.moveDirection = ""; // 停止移动方向
  }


  isVictoryPositionVisible(x: number, y: number): boolean { // 判断位置是否为胜利位置
    return this.victoryPositions.some(position => position.x === x && position.y === y); // 返回是否有胜利位置与给定位置匹配
  }
  isCratePositionVisible(x: number, y: number): boolean { // 判断位置是否为箱子位置
    return this.cratePositions.some(position => position.x === x && position.y === y); // 返回是否有箱子位置与给定位置匹配
  }
  isPlayerPositionVisible(x: number, y: number): boolean { // 判断位置是否为玩家位置
    return this.playerPosition.x === x && this.playerPosition.y === y; // 返回玩家位置是否与给定位置相同
  }

  movePlayer(direction: string) {
    // 在移动前，保存当前位置到历史位置数组
    this.historyPlayerPositions.push(new MyPosition(this.playerPosition.x,this.playerPosition.y));
    this.historyCratePositions.push(this.cratePositions.map(crate => new MyPosition(crate.x, crate.y)));

    if (this.isAnimationRunning) {
      return;
    }

    this.moveDirection = direction; // 设置当前方向
    const directions: object = Object({
      'right': Object({ dx: 0, dy:  1}),
      'left': Object({ dx:0 , dy:-1 }),
      'down': Object({ dx: 1, dy: 0 }),
      'up': Object({ dx: -1, dy: 0 })
    });
    const dx: number = directions[direction]['dx']; //{ dx, dy }
    const dy: number = directions[direction]['dy']; //{ dx, dy }
    const newX: number = this.playerPosition.x + dx;
    const newY: number = this.playerPosition.y + dy;

    // 判断目标单元格是否有效（是否越界或为墙）
    if (!this.grid[newX] || !this.grid[newX][newY] || this.grid[newX][newY].type === 1) {
      return; // 如果目标位置无效或是墙，阻止玩家移动
    }
    // 检查目标位置是否有箱子
    if (this.isCratePositionVisible(newX, newY)) {
      const crateIndex = this.cratePositions.findIndex(crate => crate.x === newX && crate.y === newY);
      const crateNewX = newX + dx;

      const crateNewY = newY + dy;

      // 如果箱子后方没有空间，阻止玩家和箱子移动
      if (!this.grid[crateNewX] || !this.grid[crateNewX][crateNewY] || this.grid[crateNewX][crateNewY].type !== 2 || this.isCratePositionVisible(crateNewX, crateNewY)) {
        return; // 阻止玩家和箱子移动
      }

      // 如果箱子可以移动，更新箱子位置
      this.cratePositions[crateIndex].setPosition(crateNewX, crateNewY);
      // 播放音效
      this.avPlayerManager.playSoundEffectByRawSrc('rawfile/p.mp3');// 确保路径正确
    }

    // 如果目标位置没有箱子或箱子被成功推动，则更新玩家位置
    this.playerPosition.setPosition(newX, newY);

    // 更新行走图片
    this.isAnimationRunning = true;
    this.updatePlayerImage();

      setTimeout(() => {
        this.stopPlayerAnimation(); // 停止动画并设置静止图片
        this.isAnimationRunning = false;
      }, 150); // 动画切换时间

    // 检查是否所有箱子都在胜利位置
    const allCratesOnVictory = this.cratePositions.every(crate =>
    this.victoryPositions.some(victory => crate.x === victory.x && crate.y === victory.y)
    );

    if (allCratesOnVictory) {
        const elapsed = Date.now() - this.startTime;
        if (elapsed < this.timeout) {
          console.log("恭喜你，你赢了！");
          let nextButtonText = '下一关';
          if (this.level === 5) {
            nextButtonText = '返回主页';
          }
          promptAction.showDialog({
            title: '游戏成功！',
            message: '恭喜你，用时：' + (elapsed / 1000).toFixed(3) + '秒',
            buttons: [{ text: nextButtonText, color: '#ffa500' }]
          }).then(() => {
            if (this.level !== 5) {
              this.initializeGame(this.level+1);
              this.level = this.level+1;
            }else{
              router.push({
                uri: 'pages/MenuPage', // 请根据您的实际路径调整
              });
            }


          });
        } else {
          this.gameOver(); // 时间已到，游戏失败
        }

    } else {
      // 如果没有胜利，继续游戏
      setTimeout(() => {
        this.stopPlayerAnimation(); // 停止动画并设置静止图片
        this.isAnimationRunning = false;
      }, 150);
    }
  }

  undoMove() {
    if (this.historyPlayerPositions.length > 0 && this.historyCratePositions.length > 0) {
      // 取出最后的位置
      const lastPlayerPosition = this.historyPlayerPositions.pop();
      const lastCratePositions = this.historyCratePositions.pop();

      if (lastPlayerPosition && lastCratePositions) {
        // 恢复玩家和箱子的位置
        this.playerPosition.setPosition(lastPlayerPosition.x, lastPlayerPosition.y);
        this.cratePositions = lastCratePositions.map(crate => new MyPosition(crate.x, crate.y));
      }
    }
  }

  build() {
    Column({ space: 20 }) {
      // 游戏区
      Text(`剩余时间: ${this.countdown}秒`)
        .fontSize(20)
        .fontColor("#ffffffff")
        .alignSelf(ItemAlign.End)
        .fontWeight(800)
        .margin({ top: 10, right: 20 })

      Stack() {
        // 非零区加瓷砖
        Column() {
          ForEach(this.grid, (row: [], rowIndex: number) => {
            Row() {
              ForEach(row, (item: Cell, colIndex: number) => {
                Stack() {
                  Text()
                    .width(`${this.cellWidth}lpx`)
                    .height(`${this.cellWidth}lpx`)
                    .backgroundColor(
                      item.type == 0
                        ? Color.Transparent
                        : (rowIndex + colIndex) % 2 == 0
                        ? "#cfb381"
                        : "#e1ca9f"
                    )
                    .borderRadius({
                      topLeft: item.topLeft > 10 ? item.topLeft : 0,
                      topRight: item.topRight > 10 ? item.topRight : 0,
                      bottomLeft: item.bottomLeft > 10 ? item.bottomLeft : 0,
                      bottomRight: item.bottomRight > 10 ? item.bottomRight : 0,
                    });
                  // 如果是胜利坐标，显示叉号
                  Stack() {
                    Text()
                    // 胜利坐标图片
                    Image($r('app.media.vegtor'))// 使用资源标识符加载图片
                      .width(`${this.cellWidth}lpx`)
                      .height(`${this.cellWidth}lpx`)
                      .visibility(
                        this.isVictoryPositionVisible(rowIndex, colIndex)
                          ? Visibility.Visible
                          : Visibility.None
                      );
                  }
                }
              });
            };
          });
        }

          Column() {
            ForEach(this.grid, (row: [], rowIndex: number) => {
              Row() {
                ForEach(row, (item: Cell, colIndex: number) => {
                  Stack() {
                    // 是否显示箱子
                    Stack() {
                      if (item.type === 1) {
                        // 如果类型为 1，显示 block.png
                        Image($r('app.media.block'))
                          .width(`${this.cellWidth}lpx`)
                          .height(`${this.cellWidth}lpx`)
                          .borderRadius({
                            topLeft: item.topLeft,
                            topRight: item.topRight,
                            bottomLeft: item.bottomLeft,
                            bottomRight: item.bottomRight,
                          });
                      }
                      // 箱子图片
                      Image($r('app.media.fu')) // 使用资源标识符加载图片
                        .width(`${this.cellWidth-30}lpx`)
                        .height(`${this.cellWidth-30}lpx`)
                        .backgroundColor(Color.Transparent) // 设置背景为透明
                        .visibility(
                          this.isCratePositionVisible(rowIndex, colIndex)
                            ? Visibility.Visible
                            : Visibility.None
                        );
                    }
                    .width(`${this.cellWidth}lpx`)
                    .height(`${this.cellWidth}lpx`)
                    .backgroundColor(Color.Transparent) // 设置背景为透明
                    .translate({
                      x: `${item.x}lpx`,
                      y: `${item.y}lpx`,
                    });

                  // 渲染玩家角色
                  if (this.playerPosition.x === rowIndex && this.playerPosition.y === colIndex) {
                    Image(this.playerImage)// 使用资源标识符加载图片
                      .width(`${this.cellWidth - 10}lpx`)
                      .height(`${this.cellWidth - 10}lpx`)
                      .margin({ top: 5, bottom: 5, left: 5, right: 5 }); // 添加内边距
                  }
                }
                .width(`${this.cellWidth}lpx`)
                .height(`${this.cellWidth}lpx`);

              });
            };
          });
        }
      }.margin({ top: 140})
      Stack() {
        Button("🎵")
          .onClick(() => {
            this.toggleMusic();
          }).fontSize("40px")
          .width("150px")
          .height("90px")
          .backgroundColor("#ffffffff")
          .fontColor("black")
      }.width("100px")
      .height("100px")
      .position({ top: 10, left: 10 })// 左上角


      // 其他按钮（底部横向排列）
      Row({ space: 20 }) {
        Button("重新开始")
          .backgroundColor("#ffffffff")
          .fontColor("black")
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            this.initializeGame(this.level);
          });
        Button("关卡选择")
          .backgroundColor("#ffffffff")
          .fontColor("black")
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            router.push({
              uri: 'pages/LevelPage', // 请根据您的实际路径调整
            });
          });
        Button("回退")
          .backgroundColor("#ffffffff")
          .fontColor("black")
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            this.undoMove();
          });
      }.position({x:35,y:630})


    }
    .width("105%")
    .height("100%")
    .backgroundImage($r('app.media.bg1'))
    .backgroundImageSize({ width: "100%", height: "100%" })
    .padding({ top: 20 })


    .onTouch((e) => {
      if (e.type === TouchType.Down && e.touches.length > 0) {
        // 触摸开始，记录初始位置
        this.screenStartX = e.touches[0].x;
        this.screenStartY = e.touches[0].y;
      } else if (e.type === TouchType.Up && e.changedTouches.length > 0) {
        // 当手指抬起时，更新最后的位置
        this.lastScreenX = e.changedTouches[0].x;
        this.lastScreenY = e.changedTouches[0].y;
      }
    })
    .gesture(
      SwipeGesture({ direction: SwipeDirection.All }) // 支持方向中 all可以是上下左右
        .onAction((_event: GestureEvent) => {
          const swipeX = this.lastScreenX - this.screenStartX;
          const swipeY = this.lastScreenY - this.screenStartY;
          // 清除开始位置记录，准备下一次滑动判断
          this.screenStartX = 0;
          this.screenStartY = 0;
          if (Math.abs(swipeX) > Math.abs(swipeY)) {
            if (swipeX > 0) {
              // 向右滑动
              this.movePlayer("right");
            } else {
              // 向左滑动
              this.movePlayer("left");
            }
          } else {
            if (swipeY > 0) {
              // 向下滑动
              this.movePlayer("down");
            } else {
              // 向上滑动
              this.movePlayer("up");
            }
          }
        })
    );
  }

}