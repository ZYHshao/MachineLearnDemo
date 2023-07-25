import tensorflow as tf 
# 加载模型
keras_model = tf.keras.applications.MobileNetV2(
    weights="imagenet", 
    input_shape=(224, 224, 3,),
    classes=1000,
)


import urllib
# 模型对应的索引文件地址
label_url = 'https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt'
class_labels = urllib.request.urlopen(label_url).read().splitlines()
class_labels = class_labels[1:]
assert len(class_labels) == 1000
for i, label in enumerate(class_labels):
  if isinstance(label, bytes):
    class_labels[i] = label.decode("utf8")


import coremltools as ct

# 定义输入
image_input = ct.ImageType(shape=(1, 224, 224, 3,),
                           bias=[-1,-1,-1], scale=1/127)

# 设置可预测的标签
classifier_config = ct.ClassifierConfig(class_labels)

# 进行模型转换
model = ct.convert(
    keras_model, 
    inputs=[image_input], 
    classifier_config=classifier_config,
)

# 写入元数据
model.input_description["input_1"] = "输入要分类的图片"
model.output_description["classLabel"] = "最可靠的结果"

# 模型作者
model.author = "TensorFlow转换"

# 许可
model.license = "Please see https://github.com/tensorflow/tensorflow for license information, and https://github.com/tensorflow/models/tree/master/research/slim/nets/mobilenet for the original source of the model."

# 描述
model.short_description = "图片识别模型"

# 版本号
model.version = "1.0"

# 存储模型
model.save("XMobileNetV2.mlmodel")