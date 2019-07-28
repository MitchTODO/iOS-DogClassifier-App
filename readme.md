<div>
  <img src="/readmePic/mainScreen.png " alt="Mainscreen" width="240">
  <img src="/readmePic/dogPics.png " alt="dog pictures" width="240">
  <img src="/readmePic/predict.png " alt="predict" width="240">
  <img src="/readmePic/save.png " alt="save" width="240">
  </div>


# Dog Classifier iOS App

## Description

iOS app that allows for a 120 different dog breed to be classified from a user selected image.

---

## Versions

Xcode: 10.3

Deployment Target: 12.2

---

## User Interface

UI consist of two views "DogClassifierViewController.swift" as the root view and "DogBreedImageViewController.swift"

### DogClassifierViewController

The user starts by selecting a dog image that will be used for classifying. Two bar buttons within the tool bar allow for different image sources. Left bar button allows the user to select a image from the photo library. Right bar button will present the camera and will used the captured image has the source. Source image will be used to populate the main image view and be classified by the trained neural network. Output from the neural network is presented within the table view under the main image view. Each table view cell will display the breed name by label on the left and precent of confidence for that breed on the right. A informational icon exist in each cell informing the user that the cells are press-able. Navigational bar also exist within the view containing two bar buttons. Left bar button allows for saving and sending screen results. Right will refresh the screen back to when the view did load.

_Note: Outputs are limited to only relevant classifications more about this below._


### DogBreedImageViewController

This View is presented by segue when the user presses a table cell within the root view (DogClassifierViewController). Along with the segue the breed name contained within the pressed table cell is passed allowing a network request to get all image of the relevant breed. Images are then displayed in imageView in each collection cell within a collection view.

---

## Neural Network

Apple's CreateMLUI is a fantastic library allowing for anyone to build a simply trained neural network. Some data processing was done to the dataset to increase training data and overall performance. The current model classifies at 61% accuracy this was a improvement over the 55% without data processing. (TrainedModel/ImageClassifier.mlmodel)

  <img src="/readmePic/model.png " alt="save" width="240">

From the lines below a drag n drop neural network is created. By dragging the dataset into Xcode, Xcode starts training the model.

```javascript
import CreateMLUI

let builder = MLImageClassifierBuilder()
builder.showInLiveView()
```

### DataSet

The dataset is from Stanford Dogs Dataset, this dataset seemed to be adequate at 120 different breeds but having some miss-spelled breed names.

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

The "dog.ceo" api is used to make request for dog pictures. When the app first launches a get-request is executed to retrieve a list off all dog-breeds the api supports. This is used to prevent errors and match model dog-breeds including sub-breeds to the api breed endpoint. Get function found in RequestHandler/request.swift handles all requests asynchronous. When a dog breed is selected from the table view cell and the  DogBreedImageViewController is presented the breed name associated with pressed cell is used to constructed the url path which is then used to get dog image urls. By reloading the collections view protocols (lines 57-90), data from image urls array allows each cell to be match up with url. Each cell executes a asynchronous request, for the associated image by calling the "imageForEachCell" function (line 130-147).

_Note: All network request use the same "get" function within "RequestHandler/request.swift" (68-78)_

### Decoding JSON

All incoming data is decoded into code-able structs. A "jsonDecoder"  function is used for simplicity and error handling found within "RequestHandler/request.swift" (33-54).


### Endpoints

Two base endpoints are constructed within "RequestHandler/request.swift" (13-30).

"DogEndpoint" is used to retrieve dogs image urls.

"allbreedsEndpoint" is used to retrieve all breeds including sub-breeds.


In order for model predicted names to match api documentation helper functions where constructed "Helpers/dogNameHelper.swift". Functions within allow the changing of spaces (fixErrorPhoneDogBreeds) and matching of main-breed to sub-breed (fixBreedName). Some conflicts occurred between model output dog-breed and dog-breed api endpoint, some hard coded breed-names help prevent such conflicts.

A "buildUrl" function is used to construct the full endpoint with values supplied from "fixBreedName" function. "RequestHandler/request.swift" (57-65)

### Activity Indicators

As network connectivity can be slow activity Indicators are used throughout to prevent user frustration.

---

Trimmed list of dog-breed names included sub-breeds

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


Hard-coded breed-names Found in file /Helper/dogNamehelper.swift

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


---

## Error Handling

All errors are handled by extending a function that shows a UIAlertController to the Error class. This function allows for users to be present with a friendly error message describing the error. "ErrorHandle.swift"


---

## QuickStart

---

## Sources

Dog Dataset using for training : http://vision.stanford.edu/aditya86/ImageNetDogs/

Dog Api used to load images of a breed : https://dog.ceo/dog-api/documentation/


---

## License
