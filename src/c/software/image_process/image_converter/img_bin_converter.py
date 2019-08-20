import numpy as np
import matplotlib.pyplot as plt
import PIL.Image as Image
import struct
#==============================================#
def bin2img(filename, height=800, width=480):
    f = open(filename, "rb")
    pic = np.zeros((3, height, width), dtype='u1')
    for i in range(height):
        for j in range(width):
            data = f.read(2)
            data = struct.unpack('H', data)[0]
            pixR = data >> 11
            pixG = data >> 5 & 0b111111
            pixB = data & 0b11111
            pic[0][i][j] = pixR << 3
            pic[1][i][j] = pixG << 2
            pic[2][i][j] = pixB << 3
    r=Image.fromarray(pic[0]).convert('L')
    g=Image.fromarray(pic[1]).convert('L')
    b=Image.fromarray(pic[2]).convert('L')
    image = Image.merge("RGB", (r, g, b))
    image.save(filename+'.bmp')
    plt.imshow(image)
    plt.show()
    f.close()
#==============================================#
def img2bin(filename, height=800, width=480):
    img = Image.open(filename)
    if(img.mode != 'RGB'):
        img = img.convert("RGB")
    img = np.array(img)
    data = bytearray(height * width * 2)
    ptr = 0
    for i in range(height):
        for j in range(width):
            pixR = img[i][j][0] >> 3
            pixG = img[i][j][1] >> 2
            pixB = img[i][j][2] >> 3
            pack = (pixR << 11) | (pixG << 5) | pixB
            data[ptr+0] = pack & 0xFF
            data[ptr+1] = pack >> 8 & 0xFF
            ptr += 2
    bin_file = open(filename+'.bin','wb')
    bin_file.write(data)
    bin_file.close()
#==============================================#
#img2bin('1.bmp')
#bin2img('1.bin')
