import Foundation
import UIKit

extension UIImage {
    // https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        // ビットマップを格納する配列を初期化（RGBA各成分が1バイト、計4バイト）。色成分にアクセスするために必要。
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: CGFloat(bitmap[3]) / 255
        )
    }
}

extension UIColor {
    /// 相対輝度
    ///
    ///　相対輝度は、人間の目が色の明るさをどのように感じるかを表す指標。
    ///　RGB成分の加重平均を使って計算される。この加重平均は、人間の目が異なる波長の光に対して異なる感度を持つことに基づいている。
    var relativeLuminance: CGFloat {
        return 0.2126 * components.red + 0.7152 * components.green + 0.0722 * components.blue
    }

    private var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var redComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var alphaComponent: CGFloat = 0

        self.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha: &alphaComponent)

        return (redComponent, greenComponent, blueComponent, alphaComponent)
    }
}

