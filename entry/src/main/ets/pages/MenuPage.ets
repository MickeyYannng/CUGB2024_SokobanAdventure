import router from '@system.router';
@Entry
@Component
struct MenuPage {
  @State message: string = '菜单页';

  build() {
    RelativeContainer() {
      // 背景图片
      Image($rawfile('menubg.png'))
        .id('BackgroundImage')
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Top },
        })
        .width('100%')
        .height(220)
        .margin({ top: 140 }); // 调整 top 值以向下移动

      RelativeContainer() {
        Text('推箱子大冒险')
          .id('GameTitle')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Top }, // 垂直居中
            middle: { anchor: '__container__', align: HorizontalAlign.Center }, // 水平居中
          })
          .margin({ top: 300 }); // 微调垂直偏移
      }


      // 按钮组
      Column() {
        Button('关卡选择')
          .id('ClassicModeButton')
          .fontSize(25)
          .backgroundColor('#ffefb66c')
          .fontColor('#ff000000')
          .margin({ bottom: 50 })
          .width(300) // 设置按钮宽度
          .height(70) // 设置按钮高度
          .onClick(() => this.startLevelMode());

        Button('排行榜')
          .id('LeaderboardButton')
          .fontSize(25)
          .backgroundColor('#ffd485d4')
          .fontColor('#ff000000')
          .margin({ bottom: 50 })
          .width(300) // 设置按钮宽度
          .height(70) // 设置按钮高度
          .onClick(() => {
            router.push({
              uri: 'pages/RankPage', // 请根据您的实际路径调整
            });
          });


        Button('退出游戏')
          .id('ExitGameButton')
          .fontSize(25)
          .backgroundColor('#ff54aeff')
          .fontColor('#ff000000')
          .width(300) // 设置按钮宽度
          .height(70) // 设置按钮高度
          .onClick(() => this.exitGame());
      }
      .id('ButtonGroup')
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
      })
      .margin({ top: 130 })
      .padding(50);


      // 当前状态信息
      Text('当前短通关时间：23s\n已完成关卡：3')
        .id('GameStats')
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Bottom },
        })
        .margin({ bottom: 30 })
        .margin({ left: 110 });
    }
    .height('100%')
    .width('100%');
  }

  startLevelMode() {
    router.push({
      uri: 'pages/LevelPage', // 请根据您的实际路径调整
    });
  }

  openLeaderboard() {
    // 打开排行榜页面逻辑
  }

  exitGame() {
    // 退出游戏逻辑
  }
}
