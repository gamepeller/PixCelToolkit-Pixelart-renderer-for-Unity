# PixCeltToolkit-Pixelart-renderer-for-Unity![image_008_0000](https://user-images.githubusercontent.com/83895158/191230072-1874d45e-1140-405f-97c5-7f11888c0fcd.jpg)
Instructions:
step 1: implement your own image effect/blit render feature, or just import this one https://github.com/Cyanilux/URP_BlitRenderFeature.git

step 2: make sure your render camera and display camera don't use the same renderer, you only want to be adding the image effects to the render camera

step 3: create a new layer named "Display Camera"

step 4: add the "Force Depth Normals" render feature to the render camera renderer, only necessary for the outline

step 5: to use either feature, add a blit render feature and assign the appropriate material

the shaders work perfectly in built-in as well, just use built-in's version of blit which you do through a c# script


To use demo project, unpack it then add project from disk in unity hub, first time around it's gonna load for a long time due to removal of library folder to reduce size, don't be alarmed. 
