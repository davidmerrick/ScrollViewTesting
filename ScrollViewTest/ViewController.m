//
//  ViewController.m
//  ScrollViewTest
//
//  Created by David Merrick on 3/15/14.
//  Copyright (c) 2014 David Merrick. All rights reserved.
//
// Based on code from http://www.raywenderlich.com/10518/how-to-use-uiscrollview-to-scroll-and-zoom-content
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.imageView.image = [UIImage imageNamed:@"photo1.png"];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.imageView.image.size};
    self.scrollView.contentSize = self.imageView.image.size;
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;

    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;

    [self centerScrollViewContents:self.scrollView];
}

- (IBAction)cropImage:(id)sender {
	//Crops the image in the scrollView and puts the final image in the finalImageView
	UIScrollView *scrollView = self.scrollView;
	UIImageView *imageView = (UIImageView*)[scrollView.subviews objectAtIndex:0];
	
	//Calculate the required area from the scrollview
    CGRect visibleRect;
    float scale = 1.0f/scrollView.zoomScale;
    visibleRect.origin.x = scrollView.contentOffset.x * scale;
    visibleRect.origin.y = scrollView.contentOffset.y * scale;
    visibleRect.size.width = scrollView.bounds.size.width * scale;
    visibleRect.size.height = scrollView.bounds.size.height * scale;
	
    self.finalImageView.image = imageFromView(imageView.image, &visibleRect);
}

UIImage* imageFromView(UIImage* srcImage, CGRect* rect)
{
    CGImageRef cr = CGImageCreateWithImageInRect(srcImage.CGImage, *rect);
    UIImage* cropped = [UIImage imageWithCGImage:cr];
	
    CGImageRelease(cr);
    return cropped;
}

- (void)centerScrollViewContents:(UIScrollView*)scrollView {
    CGSize boundsSize = scrollView.bounds.size;

	//Retrieve child image view
    UIImageView *imageView = (UIImageView*)[scrollView.subviews objectAtIndex:0];
	CGRect contentsFrame = imageView.frame;
	
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
	
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
	
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)sender {
    CGPoint pointInView = [sender locationInView:self.imageView];

	UIScrollView *scrollView = (UIScrollView*)sender.view;
	
    CGFloat newZoomScale = scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, scrollView.maximumZoomScale);
	
    CGSize scrollViewSize = scrollView.bounds.size;
	
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
	
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
	
    [scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)sender {
    UIScrollView *scrollView = (UIScrollView*)sender.view;
	
	// Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents:scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
