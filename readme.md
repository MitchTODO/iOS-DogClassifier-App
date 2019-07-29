
# Dog Classifier iOS App

## Description

iOS app that allows for a 120 different dog breed to be classified from a user selected image.

---

## Versions

Xcode: 10.3

Deployment Target: 12.2

---

## User Interface

UI consist of two views, "DogClassifierViewController.swift" as the root and "DogBreedImageViewController.swift"

### DogClassifierViewController

The user starts by selecting a dog image for classifying. Two bar buttons within the tool bar allow for different image sources. Left bar button enables the user to select an image from the photo library. Right bar button displays the camera to capture an image. Source image populates the main image view and classified by the trained neural network. Output from the neural network is presented in the table view under the main image. Each table cell displays the breed name on left and precent of confidence on right side. Informational icon exist in each cell informing the user that the cells are "press-able". Navigational bar contains two bar buttons, left bar button enables saving and sending screen results. Right refreshes the screen back to when the "view did load".

<div> 
  <img src="/readmePic/mainScreen.png " alt="Mainscreen" width="240">
  <img src="/readmePic/predict.png " alt="predict" width="240">
  
  <img src="/readmePic/save.png " alt="save" width="240">
</div>

_Note: Outputs are limited to only relevant classifications more about this below._

### DogBreedImageViewController

This view is presented when the user selects a table cell from the root view (DogClassifierViewController). A segue is triggered and passes the selected breed name. Allowing a network request to get images of that breed. Images are then displayed in each collection cell filling the view.

<div> 
  <img src="/readmePic/dogPics.png " alt="dog pictures" width="240">
  </div>

---

## Neural Network

Apple's CreateMLUI is a fantastic library allowing for anyone to build a simply trained neural network. Some data processing was done to the dataset to increase training data and overall performance. The current model classifies at 61% accuracy this improved from the 55% without data processing. (TrainedModel/ImageClassifier.mlmodel)

  <img src="/readmePic/model.png " alt="save" width="240">

From the lines below a drag n drop neural network is created. Training begins when the dataset is dragged into Xcode.

```javascript
import CreateMLUI

let builder = MLImageClassifierBuilder()
builder.showInLiveView()
```

### DataSet

The dataset is from "Stanford Dogs Dataset", this dataset consist of 120 different breeds and 20,580 images.

http://vision.stanford.edu/aditya86/ImageNetDogs/

Data processing included blurring and flipping images.

<div>
  <img src="/readmePic/orginal.jpg " alt="Original" width="240">
  <img src="/readmePic/flippedOriginal.jpg " alt="flippedOriginal" width="240">
  <img src="/readmePic/blurr.jpg " alt="blurred" width="240">
  <img src="/readmePic/flippedBlurr.jpg " alt="flippedblurr" width="240">
  </div>

### Classifying a image

Image classifying first starts by having the user select a source image. The source image is then passed into a private "predictImage" function within the "DogClassifierViewController" (lines 237-272). PredictImage function will first crop and resize the image to fit the model (299 x 299) this is done by a UIImage Class extension "Helpers/imageHelper.swift". Then the image will be passed into the model. Model outputs a dictionary. Dictionary keys are the breed name and key values are precent of confidence. Values are then sorted from greatest to lowest and filtered by keeping keys greater then zero precent. Each item that passes the filter is separated and appended to arrays. By reloading the table view the table protocol functions (lines 276-303) will read from the arrays and populate the table. By sorting the dictionary the table cells are already sorted with the most likely dog breed at the top.

_Note: predictImage is asynchronous with a QoS put in place has model prediction can be cpu intensive_

---

## Networking

The "dog.ceo" api is used to display dog images based on breed. When the app first launches a get-request is executed to retrieve a list of all dog-breeds the api supports. This is used to prevent errors and match model output to the api breed endpoint. "Get" function, found in "RequestHandler/request.swift", handles all asynchronous requests. After the DogBreedImageViewController is presented, the breed name associated with pressed table cell is used to build a url path. The fully constructed url retrieves all image urls associated with the selected breed. Each cell created is matched with a single image url used to executes an asynchronous request.

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

All errors are handled by extending a function that shows a UIAlertController to the Error class. This function allows for users to be present with a friendly error message describing the error. "ErrorHandle.swift"
"""
## No Core Data

Core data is not necessary since user has the ability to save / share.

---

## QuickStart

---

## Sources

Dog Dataset using for training : http://vision.stanford.edu/aditya86/ImageNetDogs/

Dog Api used to load images of a breed : https://dog.ceo/dog-api/documentation/


---

## License
