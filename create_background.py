from PIL import Image

# 创建一个更大的纯色背景图片，以适应49个格子
img = Image.new('RGB', (1600, 900), (255, 255, 255))
# 保存图片
img.save('/Users/jmspay/Desktop/game/assets/background.png')
print("更大的纯色背景图片已创建成功！")