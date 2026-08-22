from PIL import Image

img1 = Image.open('01_mobile_portrait.png')
img2 = Image.open('02_tablet_portrait.png')

width = img1.width + img2.width + 20
height = max(img1.height, img2.height)

new_img = Image.new('RGB', (width, height), (255, 255, 255))
new_img.paste(img1, (0, 0))
new_img.paste(img2, (img1.width + 20, 0))
new_img.save('08_layout_comparison.png')
