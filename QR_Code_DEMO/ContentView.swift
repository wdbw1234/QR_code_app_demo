//
//  ContentView.swift
//  QR_Code_DEMO
//
//

import SwiftUI
import AVFoundation

struct ContentView: View {

    @State var image:UIImage = UIImage(named: "Default_Image.png")!
    @State var showImagePicker: Bool = false
    @State var showCameraPicker: Bool = false
    
    @State var alpha: UInt8 = 0
    @State var red: UInt = 1000
    @State var green: UInt = 1000
    @State var blue: UInt = 1000
    
    public func checkForPermissions() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { _ in
            })
            break
            
        default:
            break
        }
    }
    
    func openCamera() {
        checkForPermissions()
    }
    
    func getPixelColor() {
        guard
            let cgImage = self.image.cgImage,
            let data = cgImage.dataProvider?.data,
            let dataPtr = CFDataGetBytePtr(data)
        else {
            return
        }
        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = cgImage.bitsPerPixel/8
        
        let xt = cgImage.width / 2
        let yt = cgImage.height / 2
        let pixelOffset = yt*bytesPerRow + xt*bytesPerPixel
        
//        alpha = dataPtr[pixelOffset + 0]
        red = UInt(dataPtr[pixelOffset + 0])
        green = UInt(dataPtr[pixelOffset + 1])
        blue = UInt(dataPtr[pixelOffset + 2])
        
    }
    
    func getTest() -> some View {
        
/*
** Add your color logic here.
** In total three values (self.red, self.green, self.blue)
** Write your output TEXT logic to TEXT() use the similar logic below.
*/
        
        if self.red > 255 || self.blue > 255 || self.green > 255 {
            return Text("Images not set yet. ")
        }
        else if (self.red > 145 && self.blue > 150 && self.green > 150) {
            return Text("Color too faint. Please apply more solution.")
        } else if (self.red > 150 && self.blue < 100 && self.green > 150) {
            let appURL = URL(string: "https://www.bme.psu.edu/labs/yang-lab/index.htm")
            UIApplication.shared.open(appURL!)
            return Text("True")

        } else {
            return Text("False")
        }
    }
    
    var body: some View {
        VStack{
            Spacer()
            Image(uiImage: self.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
            getTest()
            Spacer()
            HStack{
                Spacer()
                Button {
                    self.showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo")
                }
                .font(.title)
                .padding(.trailing)
                
                Button {
                    self.showCameraPicker.toggle()
                } label: {
                    Image(systemName: "camera")
                }
                .font(.title)
                .padding(.trailing)

            }.padding(.bottom)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(sourceType: .photoLibrary) { image in
                        self.image = image
                        getPixelColor()
                    }
                }
                .sheet(isPresented: $showCameraPicker) {
                    ImagePicker(sourceType: .camera) { image in
                        self.image = image
                        getPixelColor()
                    }
                }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {
        
        @Binding
        private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (UIImage) -> Void
        
        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType,
             onImagePicked: @escaping (UIImage) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            onImagePicked(uiImage)
            presentationMode.dismiss()
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                           sourceType: sourceType,
                           onImagePicked: onImagePicked)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
