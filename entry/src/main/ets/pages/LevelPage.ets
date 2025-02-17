import { promptAction } from '@kit.ArkUI' // 导入ArkUI工具包中的提示操作模块
// 在 Index.ets 或其他页面文件中导入 AVPlayerManager
import router from '@system.router';
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

@ObservedV2 // 观察者模式装饰器
class Cell { // 定义游戏中的单元格类
  @Trace // 跟踪装饰器，标记属性以被跟踪
  type: number = 0; // 单元格类型，0：透明，6可移动区域,1-5关卡
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
  setPosition(x: number, y: number) { // 设置位置的方法
    this.x = x; // 更新X坐标
    this.y = y; // 更新Y坐标
  }
}
@Entry // 入口装饰器
@Component // 组件装饰器
struct Sokoban  { // 定义游戏主结构
  cellWidth: number = 100; // 单元格宽度
  @State grid: Cell[][] = [ // 游戏网格状态
    [new Cell(6), new Cell(6), new Cell(6), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(6), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(1), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(6), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(2), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(6), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(3), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(6), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(4), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(6), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(5), new Cell(6), new Cell(6)],
    [new Cell(6), new Cell(6), new Cell(6), new Cell(6), new Cell(6)],

  ];
  @State victoryPositions: MyPosition[] = [new MyPosition(), new MyPosition()]; // 胜利位置数组
  @State cratePositions: MyPosition[] = [new MyPosition(), new MyPosition()]; // 箱子位置数组
  playerPosition: MyPosition = new MyPosition(); // 玩家位置
  @State screenStartX: number = 0; // 触摸开始时的屏幕X坐标
  @State screenStartY: number = 0; // 触摸开始时的屏幕Y坐标
  @State lastScreenX: number = 0; // 触摸结束时的屏幕X坐标
  @State lastScreenY: number = 0; // 触摸结束时的屏幕Y坐标
  @State startTime: number = 0; // 游戏开始时间
  @State moveDirection: string = ""; // 当前角色移动的方向
  @State playerImage: Resource = $r('app.media.Character4'); // 初始角色图片
  isAnimationRunning: boolean = false // 动画是否正在运行
  aboutToAppear(): void { // 游戏加载前的准备工作
    this.initializeGame(); // 初始化游戏
  }
  initializeGame() { // 初始化游戏状态
    this.playerPosition.setPosition(0, 2);
  }
  isCratePositionVisible(x: number, y: number): boolean { // 判断位置是否为关卡位置
    return this.cratePositions.some(position => position.x === x && position.y === y); // 返回是否有箱子位置与给定位置匹配
  }
  isPlayerPositionVisible(x: number, y: number): boolean { // 判断位置是否为玩家位置
    return this.playerPosition.x === x && this.playerPosition.y === y; // 返回玩家位置是否与给定位置相同
  }

  checkAndNavigateToLevel(levelNumber: number) {
    if (this.isPlayerAtLevelPosition(levelNumber)) {
      console.log(`玩家到达关卡 ${levelNumber}`);
      router.push({ uri: 'pages/Index', params: { level: levelNumber } });
    }
  }

  isPlayerAtLevelPosition(levelNumber: number): boolean {
    // 判断玩家是否在某个关卡位置，假设每个关卡对应特定位置
    if (levelNumber === 1) {
      return this.playerPosition.x === 2 && this.playerPosition.y === 2; // 关卡1位置
    } else if (levelNumber === 2) {
      return this.playerPosition.x === 4 && this.playerPosition.y === 2; // 关卡2位置
    } else if (levelNumber === 3) {
      return this.playerPosition.x === 6 && this.playerPosition.y === 2; // 关卡3位置
    } else if (levelNumber === 4) {
      return this.playerPosition.x === 8 && this.playerPosition.y === 2; // 关卡4位置
    } else if (levelNumber === 5) {
      return this.playerPosition.x === 10 && this.playerPosition.y === 2; // 关卡5位置
    }
    return false;
  }

  updatePlayerImage(): void {

    const directionFrames: DirectionFrames = {
      up: [$r('app.media.Character8'), $r('app.media.Character9')],
      down: [$r('app.media.Character5'), $r('app.media.Character6')],
      left: [$r('app.media.Character10')],
      right: [$r('app.media.Character3')],
    }
    console.log("当前移动方向111:", this.moveDirection)
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


  movePlayer(direction: string) {
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

    const targetCell = this.grid[newX][newY];

    let crateIndex = -1;
    if (this.isCratePositionVisible(newX, newY)) {
      const crateBehindCell = this.grid[newX + dx][newY + dy];
      if (!crateBehindCell || crateBehindCell.type !== 2) {
        return;
      }

      crateIndex = this.cratePositions.findIndex(crate => crate.x === newX && crate.y === newY);
      if (crateIndex === -1 || this.isCratePositionVisible(newX + dx, newY + dy)) {
        return;
      }
    }

    if (this.isAnimationRunning) {
      return
    }
    // **更新方向** 在移动开始之前
    this.moveDirection = direction;
    console.log("当前移动方向:", this.moveDirection);  // 打印当前方向
    // 更新角色图片（行走动画）
    this.updatePlayerImage();

    this.isAnimationRunning = true
    animateToImmediately({
      duration: 150,
      onFinish: () => {
        animateToImmediately({
          duration: 0,
          onFinish: () => {
            this.isAnimationRunning = false
          }
        }, () => {
          if (crateIndex !== -1) {
            this.grid[this.cratePositions[crateIndex].x][this.cratePositions[crateIndex].y].x = 0;
            this.grid[this.cratePositions[crateIndex].x][this.cratePositions[crateIndex].y].y = 0;
            this.cratePositions[crateIndex].x += dx;
            this.cratePositions[crateIndex].y += dy;
          }
          this.grid[this.playerPosition.x][this.playerPosition.y].x = 0
          this.grid[this.playerPosition.x][this.playerPosition.y].y = 0
          this.playerPosition.setPosition(newX, newY);
          this.updatePlayerImage();  // 更新行走图片

          // 检查是否到达关卡位置并跳转
          for (let i = 1; i <= 5; i++) {
            this.checkAndNavigateToLevel(i);
            console.log("马上进入关卡咯")
          }
        })
      }
    }, () => {
      this.grid[this.playerPosition.x][this.playerPosition.y].x = dy * this.cellWidth;
      this.grid[this.playerPosition.x][this.playerPosition.y].y = dx * this.cellWidth;
      if (crateIndex !== -1) {
        this.grid[this.cratePositions[crateIndex].x][this.cratePositions[crateIndex].y].x = dy * this.cellWidth;
        this.grid[this.cratePositions[crateIndex].x][this.cratePositions[crateIndex].y].y = dx * this.cellWidth;
      }
      console.info(`dx:${dx},dy:${dy}`)
    });
    // 停止动画并设置静止图片
    setTimeout(() => {
      this.stopPlayerAnimation();
    }, 150); // 动画切换时间
  }

  build() {
    Column({ space: 20 }) {
      //游戏区
      Stack() {
        //非零区加瓷砖
        Column() {
          ForEach(this.grid, (row: [], rowIndex: number) => {
            Row() {
              ForEach(row, (item: Cell, colIndex: number) => {
                Stack() {
                  Text()
                    .width(`${this.cellWidth}lpx`)
                    .height(`${this.cellWidth}lpx`)
                    .backgroundColor(Color.Transparent)
                    .borderRadius({
                      topLeft: item.topLeft > 10 ? item.topLeft : 0,
                      topRight: item.topRight > 10 ? item.topRight : 0,
                      bottomLeft: item.bottomLeft > 10 ? item.bottomLeft : 0,
                      bottomRight: item.bottomRight > 10 ? item.bottomRight : 0
                    })

                }
              })
            }
          })
        }

        Column() {
          ForEach(this.grid, (row: [], rowIndex: number) => {
            Row() {
              ForEach(row, (item: Cell, colIndex: number) => {
                //是否显示箱子
                Stack() {
                  Text()
                    .width(`${this.cellWidth}lpx`)
                    .height(`${this.cellWidth}lpx`)
                    .backgroundImage(item.type == 1 ? $r('app.media.level1') :
                      item.type == 2 ? $r('app.media.level2') :
                        item.type == 3 ? $r('app.media.level3') :
                          item.type == 4 ? $r('app.media.level4') :
                            item.type == 5 ? $r('app.media.level5') : '')
                    .backgroundImageSize({ width: "110%", height: "110%" })
                    .borderRadius({
                      topLeft: item.topLeft,
                      topRight: item.topRight,
                      bottomLeft: item.bottomLeft,
                      bottomRight: item.bottomRight
                    })

                  Text()
                    .width(`${this.cellWidth - 5}lpx`)
                    .height(`${this.cellWidth - 5}lpx`)
                    .backgroundImage($r('app.media.Character4') )
                    .backgroundImageSize({ width: "100%", height: "100%" }) // 自定义大小
                    .visibility(this.isPlayerPositionVisible(rowIndex, colIndex) ? Visibility.Visible : Visibility.None)
                }
                .width(`${this.cellWidth}lpx`)
                .height(`${this.cellWidth}lpx`)
                .translate({ x: `${item.x}lpx`, y: `${item.y}lpx` })
              })
            }
          })
        }
      }

      Button('返回主页').clickEffect({ level: ClickEffectLevel.MIDDLE })
        .backgroundColor("white")
        .fontColor("black")
        .width(100)

        .onClick(() => {
          router.push({
            uri: 'pages/MenuPage', // 请根据您的实际路径调整
          });
        });

    }
    .width('100%')
    .height('100%')
    .padding({ top: 20 })
    .backgroundImage($r('app.media.background5'))
    .backgroundImageSize({ width: "100%", height: "100%" }) // 自定义大小


    .onTouch((e) => {
      if (e.type === TouchType.Down && e.touches.length > 0) { // 触摸开始，记录初始位置
        this.screenStartX = e.touches[0].x;
        this.screenStartY = e.touches[0].y;
      } else if (e.type === TouchType.Up && e.changedTouches.length > 0) { // 当手指抬起时，更新最后的位置
        this.lastScreenX = e.changedTouches[0].x;
        this.lastScreenY = e.changedTouches[0].y;
      }
    })
    .gesture(
      SwipeGesture({ direction: SwipeDirection.All })// 支持方向中 all可以是上下左右
        .onAction((_event: GestureEvent) => {
          const swipeX = this.lastScreenX - this.screenStartX;
          const swipeY = this.lastScreenY - this.screenStartY;
          // 清除开始位置记录，准备下一次滑动判断
          this.screenStartX = 0;
          this.screenStartY = 0;
          if (Math.abs(swipeX) > Math.abs(swipeY)) {
            if (swipeX > 0) {
              // 向右滑动
              this.movePlayer('right');
            } else {
              // 向左滑动
              this.movePlayer('left');
            }
          } else {
            if (swipeY > 0) {
              // 向下滑动
              this.movePlayer('down');
            } else {
              // 向上滑动
              this.movePlayer('up');
            }
          }
        })
    )
  }
}