// 定义 RankItem 接口
import router from '@system.router';
interface RankItem {
  rank: number;
  name: string;
  time: string;
}

// 定义 LevelData 接口
interface LevelData {
  title: string;
  data: RankItem[];
}

@Entry
@Component
struct RankPage {
  // 定义 levelData 的类型为 LevelData[]
  private levelData: LevelData[] = [
    {
      title: "第一关",
      data: [
        { rank: 1, name: "小兔兔", time: "00:21" },
        { rank: 2, name: "甜草莓", time: "00:45" },
        { rank: 3, name: "西高地", time: "00:46" },
      ],
    },
    {
      title: "第二关",
      data: [
        { rank: 1, name: "胡萝卜", time: "00:32" },
        { rank: 2, name: "棉花糖", time: "00:37" },
        { rank: 3, name: "奥利奥", time: "00:44" },
      ],
    },
    {
      title: "第三关",
      data: [
        { rank: 1, name: "小罗", time: "00:45" },
        { rank: 1, name: "小杨", time: "00:46" },
        { rank: 2, name: "酸奶", time: "00:58" },
      ],
    },
    {
      title: "第四关",
      data: [
        { rank: 1, name: "Tina", time: "00:52" },
        { rank: 2, name: "Mark", time: "01:02" },

      ],
    },
    {
      title: "第五关",
      data: [
        { rank: 1, name: "月亮微甜", time: "01:10" },
        { rank: 3, name: "迷糊迷糊", time: "01:15" },
      ],
    },
  ];

  build() {
    // 背景图片设置
    Stack() {
      // 背景图
      Image($r('app.media.background6'))
        .width("100%")
        .height("100%")
        .objectFit(ImageFit.Cover);

      // 排行榜内容
      Column() {
        // 页面标题
        Text("排行榜")
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          // .margin({ top: 5, bottom: 5 })
          .textAlign(TextAlign.Center)
          .fontColor("#FFFFFF")
          .width("100%")


        // 渲染每一关的排行榜
        ForEach(this.levelData, (level: LevelData) => {
          this.renderLevel(level.title, level.data);
        });
        // 添加返回按钮
        Button('返回')
          .width("400px")
          .height("110px")
          .onClick(() => {
            // 页面跳转到 MenuPage
          router.push({
            uri: 'pages/MenuPage',
          });
          })
          // .margin({ top: 20, bottom: 20 })
          .backgroundColor("#ff3487d4")
          .fontColor("#FFFFFF");
      }
      .padding(10)
      .height("100%")
      .width("100%")
      .backgroundColor(Color.Transparent); // 背景透明，展示图片
    }
  }

  // 渲染每一关的排行榜（使用 @Builder 修饰）
  @Builder
  private renderLevel(title: string, data: RankItem[]) {
    Column() {
      // 关卡标题
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor("#fffa9a60")
        .margin({ top: 5, bottom: 5 });

      // 每条数据的展示
      ForEach(data, (item: RankItem) => {
        Row() {
          // 排名图标
          Text(this.getMedalEmoji(item.rank))
            .fontSize(20)
            .margin({ right: 10 });

          // 玩家名字
          Text(item.name)
            .fontSize(20)
            .fontWeight(FontWeight.Normal)
            .flexGrow(1);

          // 通关时间
          Text(item.time).fontSize(20);
        }.margin({ top: 5, bottom: 5 });
      });
    }.margin({ bottom: 5 });
  }

  // 根据排名返回奖牌 Emoji
  private getMedalEmoji(rank: number): string {
    switch (rank) {
      case 1:
        return "🥇";
      case 2:
        return "🥈";
      case 3:
        return "🥉";
      default:
        return "";
    }
  }
}
