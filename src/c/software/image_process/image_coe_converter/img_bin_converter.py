import numpy as np
import matplotlib.pyplot as plt
import PIL.Image as Image
#==============================================#
def coe2img(filename, height=800, width=480):
    f = open(filename, "r")
    data = f.read(236)
    pic = np.zeros((3, height, width), dtype='u1')
    for i in range(height):
        for j in range(width):
            data = f.read(4)
            data = f.read(4)
            data = int(data, 16)
            pixR = data >> 11
            pixG = data >> 5 & 0b111111
            pixB = data & 0b11111
            pic[0][i][j] = pixR << 3
            pic[1][i][j] = pixG << 2
            pic[2][i][j] = pixB << 3
            data = f.read(1)
    r=Image.fromarray(pic[0]).convert('L')
    g=Image.fromarray(pic[1]).convert('L')
    b=Image.fromarray(pic[2]).convert('L')
    image = Image.merge("RGB", (r, g, b))
    image.save(filename+'.bmp')
    plt.imshow(image)
    plt.show()
    f.close()
#==============================================#
def img2coe(filename, height=800, width=480):
    head0 = 'memory_initialization_radix = 16;\nmemory_initialization_vector =\n'
    head1 = '80013600\n80020000\n80012a00\n80020000\n80012a01\n80020000\n80012a02\n'
    head2 = '80020001\n80012a03\n800200df\n80012b00\n80020000\n80012b01\n80020000\n'
    head3 = '80012b02\n80020003\n80012b03\n8002001f\n80012c00\n'
    coe = open(filename+'.coe', 'a')
    coe.write(head0 + head1 + head2 + head3)
    img = Image.open(filename)
    if(img.mode != 'RGB'):
        img = img.convert("RGB")
    img = np.array(img)
    for i in range(height):
        for j in range(width):
            pixR = img[i][j][0] >> 3
            pixG = img[i][j][1] >> 2
            pixB = img[i][j][2] >> 3
            pack = (pixR << 11) | (pixG << 5) | pixB
            data = format(pack, '04x')
            coe.write('8002'+data+'\n')
    coe.close()
#==============================================#
#img2coe('1.bmp')
#coe2img('1.coe')