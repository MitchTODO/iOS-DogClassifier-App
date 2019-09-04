


# Dog Classifier iOS App

__Note:__ This app has been accepted and is available for download on the app store. https://apps.apple.com/us/app/dog-breed-ai-classifier/id1475200198

![](/readmePic/ezgif.com-video-to-gif.gif)

## Description

iOS app classifier that will predict dog breed by passing selected image into a trained neural network model.

---

## User Interface

UI consist of three views, the user starts by selecting a dog image for classifying. Two bar buttons within the tool bar allow for different image sources. Left bar button enables the user to select an image from photo library. Right bar button displays the camera to capture an image. Source image populates main image view and is classified by the trained neural network. Output from the neural network is displayed in the table view under the main image. Each table cell displays the breed name on left and percent of confidence on right side. Informational icon exist in each cell informing user that the cells are "press-able". Navigational bar contains two bar buttons, left bar button will display privacy policy and terms and conditions. Right will display a live view of the camera feed, this feed is passed into the model allowing live predictions to be made and displayed to the title of the view.

<div>
  <img src="/readmePic/0x0ss-3.jpg " alt="Mainscreen" width="240">
  <img src="/readmePic/0x0ss-2.jpg" alt="predict" width="240">
  <img src="/readmePic/0x0ss.jpg " alt="save" width="240">
  </div>

_Note: Outputs are limited to only relevant classifications more about this below._


### DogBreedImageViewController

This controller will display up to 150 images of a specific dog breed to the user by collection view. The specific dog breed is selected within root view (DogClassifierViewController). Through the use of a segue, the breed name can be passed allowing a network request to get images.

<div>
<img src="/readmePic/dogPics.png " alt="dog pictures" width="240">
</div>

### AppInfoViewController

View displays privacy policy and terms and conditions of the app. Always accessible through the top left bar button within "DogBreedImageViewController". 

## Neural Network


Apple's CreateMLUI library was used to train the dog classifying neural network as a "mlmodel" (TrainedModel/ImageClassifier.mlmodel). CoreML library allows the utilization of the trained neural network within the app. Some additional data processing done to the dataset increased training data and overall performance. The current model classifies at 61% accuracy, improvement from 55% without data processing. (TrainedModel/ImageClassifier.mlmodel)

  <img src="/readmePic/model.png " alt="save" width="240">


### DataSet

The dataset consisties of 120 different breeds and 20,580 images.

Data processing included blurring and flipping images.

<div>
  <img src="/readmePic/orginal.jpg " alt="Original" width="240">
  <img src="/readmePic/flippedOriginal.jpg " alt="flippedOriginal" width="240">
  <img src="/readmePic/blurr.jpg " alt="blurred" width="240">
  <img src="/readmePic/flippedBlurr.jpg " alt="flippedblurr" width="240">
  </div>

### Classifying a image

Image classifying first starts by having the user select a source image. The source image is passed into a private "predictImage" function within the "DogClassifierViewController" (lines 237-272). PredictImage function crops and resize the image to fit the model through a UIImage Class extension "Helpers/imageHelper.swift". By passing the image into the model, a dictionary is returned. Dictionary keys as breed name and values as confidence level (%). Values are then sorted and filtered from greatest to zero percent. Each item passing the filter  populates the table view with highest confidence level dog breed at the top.

_Note: predictImage is asynchronous with a QoS put in place has model prediction can be cpu intensive_

---

## Networking

The "dog.ceo" api is used to display dog images based on breed. When the app first launches a get-request is executed to retrieve a list of all dog-breeds the api supports. This is used to prevent errors and match model output to the api breed endpoint. "Get" function, found in "RequestHandler/request.swift", handles all asynchronous requests. After the DogBreedImageViewController is displayed, the breed name associated with pressed table cell is used to build a url path. The fully constructed url retrieves all image urls associated with the selected breed. Each cell created is matched with a single image url used to executes an asynchronous request.

_Note: All network request use the same "get" function within "RequestHandler/request.swift" (68-78)_

### Decoding

Incoming data is decoded into code-able structs.   A "jsonDecoder"  function is used for simplicity and error handling found within "RequestHandler/request.swift" (lines 33-54).

_Note: Dog images are casted has UIImage_

### Endpoints

Two base endpoints are constructed within "RequestHandler/request.swift" (line 13-30). A "buildUrl" function is used to construct the full endpoint. "RequestHandler/request.swift" (line 57-65)

1. "DogEndpoint" is used to retrieve dogs image urls.

2. "allbreedsEndpoint" is used to retrieve all breeds including sub-breeds.


In order for model output names to match api documentation, helper functions where constructed "Helpers/dogNameHelper.swift". Functions allow the changing of spaces (fixErrorPhoneDogBreeds) and matching of main-breed to sub-breed (fixBreedName). In some cases hard coded breed names prevent any conflicts.



### Activity Indicators

If network connectivity is slow, activity indicators become visible preventing user frustration.

---

<b>Trimmed list of dog-breed names included sub-breeds</b>

```json
{
    "message": {
        "affenpinscher": [],
        "african": [],
        "airedale": [],
        "akita": [],
        "appenzeller": [],
        "basenji": [],
        "beagle": [],
        "bluetick": [],
        "borzoi": [],
        "bouvier": [],
        "boxer": [],
        "brabancon": [],
        "briard": [],
        "bulldog": [
            "boston",
            "english",
            "french"
        ],
        "bullterrier": [
            "staffordshire"
        ],
    "status": "success"
}



```


<b> Hard-coded breed-names Found in file /Helper/dogNamehelper.swift </b>

``` javascript
["boston bulldog","boston bull"],
["english hound","english foxhound"],
["stbernard","saint bernard"],
["cardigan corgi","cardigan"],
["mexicanhairless","mexican hairless"],
["westhighland terrier","west highland white terrier"],
["dandie terrier","dandie dinmont"],
["shihtzu","shih-tzu"],
["kerryblue terrier","kerry blue terrier"],
["scottish terrier","scotch terrier"],
["flatcoated retriever","flat-coated retriever"],
["blood hound","bloodhound"],
["basset hound","basset"],
["germanshepherd","german shepherd"]
```
"""

---

## Error Handling

All errors are handled by extending a function that shows a UIAlertController to the Error class. This function allows for users to be notified with a friendly error message describing the error. (ErrorHandle.swift)



---

## License

MitchTODO/iOS-DogClassifier-App is licensed under the

Apache License 2.0
A permissive license whose main conditions require preservation of copyright and license notices. Contributors provide an express grant of patent rights. Licensed works, modifications, and larger works may be distributed under different terms and without source code.
