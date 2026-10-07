from pathlib import Path
from reportlab.graphics.barcode import qr
from PIL import Image, ImageDraw

url = 'http://10.28.245.37:8080/downloads/aasha-local.apk'
code = qr.QrCodeWidget(url)
code.qr.make()
matrix = code.qr.modules
scale, border = 12, 4
image = Image.new('RGB', ((len(matrix) + border * 2) * scale,) * 2, 'white')
draw = ImageDraw.Draw(image)
for y, row in enumerate(matrix):
    for x, dark in enumerate(row):
        if dark:
            left, top = (x + border) * scale, (y + border) * scale
            draw.rectangle((left, top, left + scale - 1, top + scale - 1), fill='black')
image.save(Path(__file__).with_name('qr-local-app.png'))
print(url)
