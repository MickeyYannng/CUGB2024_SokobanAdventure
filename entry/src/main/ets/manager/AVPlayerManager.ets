import { media } from '@kit.MediaKit'

export class AVPlayerManager {
  private musicPlayer: media.AVPlayer | null = null;
  private effectPlayer: media.AVPlayer | null = null;
  private loop: boolean = false;

  async getMusicPlayerInstance() {
    if (this.musicPlayer !== null) {
      return this.musicPlayer;
    }
    const player = await media.createAVPlayer();
    player.on('stateChange', (state) => {
      switch (state) {
        case 'initialized':
          player.prepare();
          break;
        case 'prepared':
          player.play();
          break;
        case 'playing':
          player.play();
          break;
        case 'paused':
          player.pause();
          break;
        case 'completed':
          if (this.loop) {
            player.play();
          } else {
            player.stop();
          }
          break;
        case 'stopped':
          player.reset();
          break;
        default:
          break;
      }
    });
    this.musicPlayer = player;
    return this.musicPlayer;
  }

  async getEffectPlayerInstance() {
    if (this.effectPlayer !== null) {
      return this.effectPlayer;
    }
    const player = await media.createAVPlayer();
    player.on('stateChange', (state) => {
      if (state === 'completed') {
        player.reset();
      }
    });
    this.effectPlayer = player;
    return this.effectPlayer;
  }

  async playMusicByRawSrc(rawFdPath: string) {
    const player = await this.getMusicPlayerInstance();
    await player.reset();
    const context = getContext();
    const fileDescriptor = await context.resourceManager.getRawFd(rawFdPath);
    player.fdSrc = fileDescriptor;
    player.loop = true; // Ensure music loops
    player.play();
  }

  async playSoundEffectByRawSrc(rawFdPath: string) {
    const player = await this.getEffectPlayerInstance();
    await player.reset();
    const context = getContext();
    const fileDescriptor = await context.resourceManager.getRawFd(rawFdPath);
    player.fdSrc = fileDescriptor;
    player.play();
  }

  async stopMusic() {
    const player = await this.getMusicPlayerInstance();
    player.pause();
  }

  async continueMusic() {
    const player = await this.getMusicPlayerInstance();
    player.play();
  }
}

export const avPlayerManager = new AVPlayerManager();