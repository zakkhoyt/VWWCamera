//
//  VWWViewController.m
//  VWWCamera
//
//  Created by Zakk Hoyt on 4/5/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWFilterViewController.h"
#import "GPUImage.h"


@interface VWWFilterViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, GPUImageVideoCameraDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *albumButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (nonatomic, strong) UIImage *originalImage;
@end

@implementation VWWFilterViewController

#pragma mark UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.navigationController setNavigationBarHidden:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}
#pragma mark Private methods

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;
    
    if(!error)
    {
        alertTitle   = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark IBActions
- (IBAction)albumButtonTouchUpInside:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:photoPicker animated:YES completion:NULL];
    
}
- (IBAction)cameraButtonTouchUpInside:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:photoPicker animated:YES completion:NULL];
    
}

- (IBAction)filterButtonTouchUpInside:(id)sender {
    UIActionSheet *filterActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Filter"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"Grayscale", @"Sepia", @"Sketch", @"Pixellate", @"Color Invert", @"Toon", @"Pinch Distort", @"Blur", @"None", nil];
    
    [filterActionSheet showFromBarButtonItem:sender animated:YES];

}
- (IBAction)saveButtonTouchUpInside:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.selectedImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (IBAction)faceButtonTouchUpInside:(id)sender {
        [self faceDetector];
}

#pragma mark UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.saveButton.enabled = YES;
    self.filterButton.enabled = YES;
    
    self.originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.selectedImageView setImage:self.originalImage];
    
    [photoPicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    GPUImageFilter *selectedFilter;
    switch (buttonIndex) {
        case 0:
            selectedFilter = [[GPUImageGrayscaleFilter alloc] init];
            break;
        case 1:
            selectedFilter = [[GPUImageSepiaFilter alloc] init];
            break;
        case 2:
            selectedFilter = [[GPUImageSketchFilter alloc] init];
            break;
        case 3:
            selectedFilter = [[GPUImagePixellateFilter alloc] init];
            break;
        case 4:
            selectedFilter = [[GPUImageColorInvertFilter alloc] init];
            break;
        case 5:
            selectedFilter = [[GPUImageToonFilter alloc] init];
            break;
        case 6:
            selectedFilter = [[GPUImagePinchDistortionFilter alloc] init];
            break;
        case 7:{
            GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc]init];
            selectedFilter = (GPUImageFilter*)blurFilter;
        }
            break;
        case 8:
            selectedFilter = [[GPUImageFilter alloc] init];
            break;
        default:
            break;
    }
    
    UIImage *filteredImage = [selectedFilter imageByFilteringImage:self.originalImage];
    [self.selectedImageView setImage:filteredImage];
}


- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    [self.selectedImageView setNeedsDisplay];
}



-(void)faceDetector
{
    // Load the picture for face detection
    UIImageView* image = [[UIImageView alloc] initWithImage:
                          self.originalImage];
    
    // Draw the face detection image
    [self.view addSubview:image];
    
    // Execute the method used to markFaces in background
    [self markFaces:image];
    
//    // flip image on y-axis to match coordinate system used by core image
//    [image setTransform:CGAffineTransformMakeScale(1, -1)];
    
//    // flip the entire window to make everything right side up
//    [self.view setTransform:CGAffineTransformMakeScale(1, -1)];
}


-(void)markFaces:(UIImageView *)facePicture
{
    // draw a CI image with the previously loaded face detection picture
    CIImage* image = [CIImage imageWithCGImage:facePicture.image.CGImage];
    
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];



    
//    CIDetectorImageOrientation
    // create an array containing all the detected faces from the detector
//    NSArray* features = [detector featuresInImage:image];
    NSArray* features = [detector featuresInImage:image options:@{CIDetectorImageOrientation : @(1)}];
    
    // we'll iterate through every detected face. CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected. Also provided are BOOL's for the eye's and
    // mouth so we can check if they already exist.
    for(CIFaceFeature* faceFeature in features)
    {
        // get the width of the face
        CGFloat faceWidth = faceFeature.bounds.size.width;
        
        
        // create a UIView using the bounds of the face
        CGRect faceViewBounds = faceFeature.bounds;
        faceViewBounds.origin.y = faceViewBounds.size.height - faceViewBounds.origin.y;
        UIView* faceView = [[UIView alloc] initWithFrame:faceViewBounds];
        
        // add a border around the newly created UIView
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor greenColor] CGColor];
        
        // add the new view to create a box around the face
        [facePicture addSubview:faceView];
        

        
        
        
        if(faceFeature.hasLeftEyePosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15,
                                                                           faceFeature.leftEyePosition.y-faceWidth*0.15,
                                                                           faceWidth*0.3,
                                                                           faceWidth*0.3)];
            // change the background color of the eye view
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the leftEyeView based on the face
            CGPoint center = faceFeature.leftEyePosition;
            center.y = facePicture.image.size.height - center.y;
            [leftEyeView setCenter:center];
            // round the corners
            leftEyeView.layer.cornerRadius = faceWidth*0.15;
            // add the view to the window
            [facePicture addSubview:leftEyeView];
        }
        
        if(faceFeature.hasRightEyePosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* leftEye = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15,
                                                                       faceFeature.rightEyePosition.y-faceWidth*0.15,
                                                                       faceWidth*0.3,
                                                                       faceWidth*0.3)];
            // change the background color of the eye view
            [leftEye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the rightEyeView based on the face
            CGPoint center = faceFeature.rightEyePosition;
            center.y = facePicture.image.size.height - center.y;
            [leftEye setCenter:center];
            // round the corners
            leftEye.layer.cornerRadius = faceWidth*0.15;
            // add the new view to the window
            [facePicture addSubview:leftEye];
        }
        
        if(faceFeature.hasMouthPosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* mouth = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2,
                                                                     faceFeature.mouthPosition.y-faceWidth*0.2,
                                                                     faceWidth*0.4,
                                                                     faceWidth*0.4)];
            // change the background color for the mouth to green
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            // set the position of the mouthView based on the face
            CGPoint center = faceFeature.mouthPosition;
            center.y = facePicture.image.size.height - center.y;
            [mouth setCenter:center];
            // round the corners
            mouth.layer.cornerRadius = faceWidth*0.2;
            // add the new view to the window
            [facePicture addSubview:mouth];
        }
        
    }
    
    

}



@end

