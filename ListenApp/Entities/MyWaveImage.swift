//
//  MyWaveImage.swift
//  ListenApp
//
//  Created by 곽지혁 on 2023/02/14.
//

import Foundation
import AVFoundation
import UIKit
import CoreGraphics

enum Waveform {
    /**
     Position of the drawn waveform:
     - **top**: Draws the waveform at the top of the image, such that only the bottom 50% are visible.
     - **top**: Draws the waveform in the middle the image, such that the entire waveform is visible.
     - **bottom**: Draws the waveform at the bottom of the image, such that only the top 50% are visible.
     */
    public enum Position: Equatable {
        case top
        case middle
        case bottom
        case custom(Double)

        func value() -> Double {
            switch self {
            case .top: return 0.0
            case .middle: return 0.5
            case .bottom: return 1.0
            case .custom(let value): return min(1.0, max(0.0, value))
            }
        }
    }

    public struct StripeConfig: Equatable {
        /// Color of the waveform stripes. Default is clear.
        public let color: UIColor

        /// Width of stripes drawn. Default is `1`
        public let width: CGFloat

        /// Space between stripes. Default is `5`
        public let spacing: CGFloat

        /// Line cap style. Default is `.round`.
        public let lineCap: CGLineCap

        public init(color: UIColor, width: CGFloat = 1, spacing: CGFloat = 5, lineCap: CGLineCap = .round) {
            self.color = color
            self.width = width
            self.spacing = spacing
            self.lineCap = lineCap
        }
    }


    /**
     Defines the dampening attributes of the waveform.
     */
    public struct Dampening {
        public enum Sides {
            case left
            case right
            case both
        }

        /// Determines the percentage of the resulting graph to be dampened.
        ///
        /// Must be within `(0..<0.5)` to leave an undapmened area.
        /// Default is `0.125`
        public let percentage: Float

        /// Determines which sides of the graph to dampen.
        /// Default is `.both`
        public let sides: Sides

        /// Easing function to be used. Default is `pow(x, 2)`.
        public let easing: (Float) -> Float

        public init(percentage: Float = 0.125, sides: Sides = .both, easing: @escaping (Float) -> Float = { x in pow(x, 2) }) {
            guard (0...0.5).contains(percentage) else {
                preconditionFailure("dampeningPercentage must be within (0..<0.5)")
            }

            self.percentage = percentage
            self.sides = sides
            self.easing = easing
        }

        /// Build a new `Waveform.Dampening` with only the given parameters replaced.
        public func with(percentage: Float? = nil, sides: Sides? = nil, easing: ((Float) -> Float)? = nil) -> Dampening {
            .init(percentage: percentage ?? self.percentage, sides: sides ?? self.sides, easing: easing ?? self.easing)
        }
    }

    /// Allows customization of the waveform output image.
    public struct Configuration {
        /// Desired output size of the waveform image, works together with scale. Default is `.zero`.
        public let size: CGSize

        /// Background color of the waveform, defaults to `clear`.
        public let backgroundColor: UIColor

        /// Waveform drawing style, defaults to `.gradient`.
        public let stripeConfig: StripeConfig

        /// *Optional* Waveform dampening, defaults to `nil`.
        public let dampening: Dampening?

        /// Waveform drawing position, defaults to `.middle`.
        public let position: Position

        /// Scale (@2x, @3x, etc.) to be applied to the image, defaults to `UIScreen.main.scale`.
        public let scale: CGFloat

        /// *Optional* padding or vertical shrinking factor for the waveform.
        @available(swift, obsoleted: 3.0, message: "Please use scalingFactor instead")
        public let paddingFactor: CGFloat? = nil

        /**
         Vertical scaling factor. Default is `0.95`, leaving a small vertical padding.

         The `verticalScalingFactor` replaced `paddingFactor` to be more approachable.
         It describes the maximum vertical amplitude of the envelope being drawn
         in relation to its view's (image's) size.

         * `0`: the waveform has no vertical amplitude and is just a line.
         * `1`: the waveform uses the full available vertical space.
         * `> 1`: louder waveform samples will extend out of the view boundaries and clip.
         */
        public let verticalScalingFactor: CGFloat

        /// Waveform antialiasing. If enabled, may reduce overall opacity. Default is `false`.
        public let shouldAntialias: Bool

        var shouldDampen: Bool {
            dampening != nil
        }


        public init(size: CGSize = .zero,
                    backgroundColor: UIColor = UIColor.clear,
                    stripeConfig: StripeConfig = .init(color: .label),
                    dampening: Dampening? = nil,
                    position: Position = .middle,
                    scale: CGFloat = UIScreen.main.scale,
                    verticalScalingFactor: CGFloat = 0.95,
                    shouldAntialias: Bool = false) {
            guard verticalScalingFactor > 0 else {
                preconditionFailure("verticalScalingFactor must be greater 0")
            }

            self.backgroundColor = backgroundColor
            self.stripeConfig = stripeConfig
            self.dampening = dampening
            self.position = position
            self.size = size
            self.scale = scale
            self.verticalScalingFactor = verticalScalingFactor
            self.shouldAntialias = shouldAntialias
        }
    }

}


class MyWaveformImageDrawer {
    let audio = PlayerController.playerController.audio!
    private var lastOffset = 0
    
    public func waveformImage(from range: Range<Int>, with configuration: Waveform.Configuration) -> UIImage? {
        guard range.count > 0, range.count == Int(configuration.size.width * configuration.scale) else {
            print("ERROR: samples: \(range.count) != \(configuration.size.width) * \(configuration.scale)")
            return nil
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = configuration.scale
        let renderer = UIGraphicsImageRenderer(size: configuration.size, format: format)
//        let dampenedSamples = configuration.shouldDampen ? dampen(samples, with: configuration) : samples

        return renderer.image { renderContext in
            draw(on: renderContext.cgContext, from: range, with: configuration)
        }
    }
    
    public func drawEmptyImage(with configuration: Waveform.Configuration) -> UIImage? {

        let format = UIGraphicsImageRendererFormat()
        format.scale = configuration.scale
        let renderer = UIGraphicsImageRenderer(size: configuration.size, format: format)
//        let dampenedSamples = configuration.shouldDampen ? dampen(samples, with: configuration) : samples

        return renderer.image { renderContext in
            drawBackground(on: renderContext.cgContext, with: configuration)
        }
    }
    
    private func draw(on context: CGContext, from range: Range<Int>, with configuration: Waveform.Configuration) {
        context.setAllowsAntialiasing(configuration.shouldAntialias)
        context.setShouldAntialias(configuration.shouldAntialias)

        drawBackground(on: context, with: configuration)
        drawSection(from: range, on: context, with: configuration)
        drawSectionRepeat(from: range, on: context, with: configuration)
        drawGraph(from: range, on: context, with: configuration)
        drawGraduation(from: range, on: context, with: configuration)
        drawABIndicator(from: range, on: context, with: configuration)
    }
    
    private func drawABIndicator(from range: Range<Int>, on context: CGContext, with configuration: Waveform.Configuration) {
        if let positionA = PlayerController.playerController.positionA {
            let xPos = Double(positionA - range.lowerBound)
            drawIndicator(context: context, xPos: xPos, color : UIColor.red.cgColor, configuration: configuration)
        }
        if let positionB = PlayerController.playerController.positionB {
            let xPos = Double(positionB - range.lowerBound)
            drawIndicator(context: context, xPos: xPos, color : UIColor.blue.cgColor, configuration: configuration)
        }
        
    }
    
    private func drawSectionRepeat(from range: Range<Int>, on context: CGContext, with configuration: Waveform.Configuration) {
        if !PlayerController.playerController.shouldSectionRepeat { return }
        
        let path = CGMutablePath()
        let sectionStart = PlayerController.playerController.positionSectionStart!
        let sectionEnd = PlayerController.playerController.positionSectionEnd!
    
        if range.lowerBound < sectionEnd {
            let xPos = Double(sectionStart - range.lowerBound)
            let rectWidth = Double(sectionEnd - sectionStart)
            
            if range.upperBound < sectionEnd {
                if sectionStart < range.upperBound {
                    // 이미지 끝이 섹션의 중간부분임
                    path.move(to: CGPoint(x: xPos, y: configuration.size.height * 0.05))
                    let rectangle = CGRect(
                        x: xPos,
                        y: 50,
                        width: Double(range.upperBound - sectionStart),
                        height: configuration.size.height - 120)
                    path.addRect(rectangle)
                }
            }
            
            if sectionStart < range.lowerBound {
                // 이미지 시작이 섹션의 중간부분임
                path.move(to: CGPoint(x: xPos, y: configuration.size.height * 0.05))
                let rectangle = CGRect(
                    x: 0,
                    y: 50,
                    width: Double(sectionEnd - range.lowerBound),
                    height: configuration.size.height - 120)
                path.addRect(rectangle)
            }
            else{
                // 온전한 섹션파트 그리기
                path.move(to: CGPoint(x: xPos, y: configuration.size.height * 0.05))
                let rectangle = CGRect(
                    x: xPos,
                    y: 50,
                    width: rectWidth,
                    height: configuration.size.height - 120)
                path.addRect(rectangle)
            }
        }
            
        
        context.addPath(path)
        
        context.setFillColor(UIColor.yellow.cgColor)
        context.setLineWidth(0)
        context.setAlpha(1)
        
        context.drawPath(using: .fillStroke)
    }
    
    private func drawBackground(on context: CGContext, with configuration: Waveform.Configuration) {
        context.setFillColor(configuration.backgroundColor.cgColor)
        let size = CGSize(width: configuration.size.width, height: configuration.size.height - 60)
        context.fill(CGRect(origin: CGPoint(x: 0, y: 20), size: size))
    }
    
    
    private func drawSection(from range: Range<Int>, on context: CGContext, with configuration: Waveform.Configuration) {
        let path = CGMutablePath()
        var section = 0
        
        while section < audio.sectionStart.count {
            if range.lowerBound < audio.sectionEnd[section] {
                let xPos = Double(audio.sectionStart[section] - range.lowerBound)
                let rectWidth = Double(audio.sectionEnd[section] - audio.sectionStart[section])
                
                if range.upperBound < audio.sectionEnd[section] {
                    if audio.sectionStart[section] < range.upperBound {
                        // 이미지 끝이 섹션의 중간부분임
                        path.move(to: CGPoint(x: xPos, y: configuration.size.height * 0.05))
                        let rectangle = CGRect(
                            x: xPos,
                            y: 50,
                            width: Double(range.upperBound - audio.sectionStart[section]),
                            height: configuration.size.height - 120)
                        path.addRect(rectangle)
                    }
                    break
                }
                
                if audio.sectionStart[section] < range.lowerBound {
                    // 이미지 시작이 섹션의 중간부분임
                    path.move(to: CGPoint(x: xPos, y: configuration.size.height * 0.05))
                    let rectangle = CGRect(
                        x: 0,
                        y: 50,
                        width: Double(audio.sectionEnd[section] - range.lowerBound),
                        height: configuration.size.height - 120)
                    path.addRect(rectangle)
                }
                else{
                    // 온전한 섹션파트 그리기
                    path.move(to: CGPoint(x: xPos, y: configuration.size.height * 0.05))
                    let rectangle = CGRect(
                        x: xPos,
                        y: 50,
                        width: rectWidth,
                        height: configuration.size.height - 120)
                    path.addRect(rectangle)
                }
                
            }
            
            section += 1
        }
        
        context.addPath(path)
        
        context.setFillColor(UIColor.yellow.cgColor)
        context.setLineWidth(0)
        context.setAlpha(0.4)
        
        context.drawPath(using: .fillStroke)
    }
    
    private func drawGraph(from range: Range<Int>,
                           on context: CGContext,
                           with configuration: Waveform.Configuration) {
        let samples = audio.waveAnalysis[range]
        let graphRect = CGRect(origin: CGPoint(x: 0, y: 0), size: configuration.size)
        let positionAdjustedGraphCenter = CGFloat(configuration.position.value()) * graphRect.size.height - 10
        let drawMappingFactor = graphRect.size.height * configuration.verticalScalingFactor
        let minimumGraphAmplitude: CGFloat = 1 / configuration.scale // we want to see at least a 1px line for silence

        let path = CGMutablePath()
        var maxAmplitude: CGFloat = 0.0 // we know 1 is our max in normalized data, but we keep it 'generic'

        for (y, sample) in samples.enumerated() {
            let x = y + lastOffset
            if x % Int(configuration.scale) != 0 || x % stripeBucket(configuration) != 0 {
                // skip sub-pixels - any x value not scale aligned
                // skip any point that is not a multiple of our bucket width (width + spacing)
                continue
            }

            let xPos = CGFloat(x - lastOffset) / configuration.scale
            let invertedDbSample = 1 - CGFloat(sample) // sample is in dB, linearly normalized to [0, 1] (1 -> -50 dB)
            let drawingAmplitude = max(minimumGraphAmplitude, invertedDbSample * drawMappingFactor)
            let drawingAmplitudeUp = positionAdjustedGraphCenter - drawingAmplitude
            let drawingAmplitudeDown = positionAdjustedGraphCenter + drawingAmplitude
            maxAmplitude = max(drawingAmplitude, maxAmplitude)

            path.move(to: CGPoint(x: xPos, y: drawingAmplitudeUp))
            path.addLine(to: CGPoint(x: xPos, y: drawingAmplitudeDown))
        }

        context.addPath(path)
        context.setAlpha(1.0)
        context.setShouldAntialias(configuration.shouldAntialias)
        
        let config = configuration.stripeConfig
        context.setLineWidth(configuration.stripeConfig.width)
        context.setLineCap(config.lineCap)
        context.setStrokeColor(config.color.cgColor)
        context.strokePath()
    }
    
    
    private func drawGraduation(from range: Range<Int>,
                                 on context: CGContext,
                                 with configuration: Waveform.Configuration) {
        
        let path = CGMutablePath()
        
        for (x, t) in range.enumerated() {
            // 눈금 그리기
            if t % 100 == 0 {
                path.move(to: CGPoint(x: x, y: Int(configuration.size.height) - 40))
                path.addLine(to: CGPoint(x: x, y: Int(configuration.size.height) - 22))
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                
                
                let time = t / 100
                let min = time / 60
                let sec = time % 60
                
                let label = UILabel()
                label.text = String(format: "%02d:%02d", min, sec)
                label.font = .systemFont(ofSize: 15)
                label.textColor = UIColor.label
                
                let labelRect = CGRect(x: x, y: Int(configuration.size.height) - 35, width: 56, height: 35)
                label.drawText(in: labelRect)
            }
            else if t % 25 == 0 {
                path.move(to: CGPoint(x: x, y: Int(configuration.size.height) - 40))
                path.addLine(to: CGPoint(x: x, y: Int(configuration.size.height) - 32))
                
            }
        }
        
        context.addPath(path)
        context.setAlpha(1.0)
        context.setShouldAntialias(configuration.shouldAntialias)
        
        let config = configuration.stripeConfig
        context.setLineWidth(1)
        context.setLineCap(config.lineCap)
        context.setStrokeColor(configuration.backgroundColor.cgColor)
        context.strokePath()
        
    }
    
    private func drawIndicator(context: CGContext, xPos: Double, color : CGColor, configuration : Waveform.Configuration) {
        let path = CGMutablePath()
        let height = configuration.size.height
        
        path.move(to: CGPoint(x: xPos, y: 0))
        path.addLine(to: CGPoint(x: xPos, y: height))
        
        context.addPath(path)
        context.setAlpha(1.0)
        context.setShouldAntialias(configuration.shouldAntialias)
        
        let config = configuration.stripeConfig
        context.setLineWidth(configuration.stripeConfig.width)
        context.setLineCap(config.lineCap)
        context.setStrokeColor(color)
        context.strokePath()
        
        let rect = CGRect(
            x: xPos-8,
            y: 0,
            width: 16,
            height: 20)
        
        let roundRect = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        context.addPath(roundRect.cgPath)
        
        context.setFillColor(color)
        context.setLineWidth(0)
        context.setAlpha(1)
        
        context.drawPath(using: .fillStroke)
    }
    
    private func stripeBucket(_ configuration: Waveform.Configuration) -> Int {
        let stripeConfig = configuration.stripeConfig
        return Int(stripeConfig.width + stripeConfig.spacing) * Int(configuration.scale)
//        return Int(stripeConfig.width) * Int(configuration.scale)
    }
}
