## **Mania Catch Converter**
This is an app for converting mania map to ctb maps. It essentially converts all long notes from mania maps to hit circles and ignore all repeated notes. 

It removes impossible pixels by calculating the trigger distance of current fruit and the next, if the distance between the current and the next is just a bit below the trigger distance it will adjust the spacing to make it a hyper jump. 

It also removes impossible hyper jumps if the time of current fruit to the next is below 100ms, this is a very simple fix that I could think of at the moment but I am sure it could be improved.

![ManiaCatchConverter_PY0nHsVBvF](https://github.com/user-attachments/assets/a926193a-ea80-4e69-8306-a421f1252cf3)


**Credits**
- Andrew: For inspiring me to create this project lol 
- Greaper: For the trigger distance calculations taken from https://greaper.net/tools/trigger-distance
