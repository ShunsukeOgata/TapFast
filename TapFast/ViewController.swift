//
//  ViewController.swift
//  TapFast
//
//  Created by Mighty on 2015/02/01.
//  Copyright (c) 2015年 Shunsuke Ogata. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation


class ViewController: UIViewController,AVAudioPlayerDelegate {
	
	var myAudioPlayer : AVAudioPlayer!	//SE
	var numButton: UIButton!			//数字ボタン
	var numCount = 0					//数字カウンタ
	var timer : NSTimer!				//タイマー
	var tmLabel : UILabel!				//タイマーラベル
	var cnt : Float = 0					//タイマーカウンタ
	var finishLabel : UILabel!			//終了ラベル
	var reButton: UIButton!				//リスタートボタン
	var recordedTime = [Float]()		//タイムの記録
	var recordText: UITextView!			//記録表示フィールド
	var recordString:String!			//記録表示文字
	var quitButton: UIButton!			//中止ボタン
	var quitLabel: UILabel!				//中止ラベル
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//音声ファイル
		let soundFilePath : NSString = NSBundle.mainBundle().pathForResource("button1", ofType: "mp3")!
		let fileURL : NSURL = NSURL(fileURLWithPath: soundFilePath)!
		myAudioPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
		myAudioPlayer.delegate = self
		
		
		//タイムラベル
		tmLabel = UILabel(frame: CGRectMake(0,0,300,80))
		tmLabel.backgroundColor = UIColor.blackColor()
		tmLabel.layer.masksToBounds = true
		tmLabel.text = "Time : 0.00s"
		tmLabel.font = UIFont.systemFontOfSize(CGFloat(40))
		tmLabel.textColor = UIColor.whiteColor()
		tmLabel.shadowColor = UIColor.grayColor()
		tmLabel.textAlignment = NSTextAlignment.Center
		tmLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 40)
		self.view.addSubview(tmLabel)
		
		
		// ナンバーボタン
		numButton = UIButton()
		numButton.frame = CGRectMake(0,0,60,60)
		numButton.backgroundColor = UIColor.blueColor();
		numButton.layer.masksToBounds = true
		numButton.setTitle("\(numCount)", forState: UIControlState.Normal)
		numButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
		numButton.layer.cornerRadius = 30.0
		numButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
		numButton.transform = CGAffineTransformMakeScale(0.01, 0.01)
		numButton.addTarget(self, action: "onDownButton:", forControlEvents: .TouchDown)
		numButton.addTarget(self, action: "onUpButton:", forControlEvents: .TouchUpInside | .TouchUpOutside)
		self.view.addSubview(numButton);
	
		
		//中止ボタン
		quitButton = UIButton()
		quitButton.frame = CGRectMake(0,0,40,40)
		quitButton.backgroundColor = UIColor.whiteColor();
		quitButton.layer.masksToBounds = true
		quitButton.setTitle("X", forState: UIControlState.Normal)
		quitButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
		quitButton.titleLabel?.font = UIFont.systemFontOfSize(CGFloat(40))
		quitButton.titleLabel?.textAlignment = NSTextAlignment.Center
		quitButton.layer.cornerRadius = 20.0
		quitButton.layer.position = CGPoint(x: self.view.frame.width - 40, y: 40)
		quitButton.transform = CGAffineTransformMakeScale(0.01, 0.01)
		quitButton.addTarget(self, action: "quitTouched:", forControlEvents: .TouchDown)
		self.view.addSubview(quitButton);
		
		
		//リスタートボタン
		reButton = UIButton()
		reButton.frame = CGRectMake(0,0,200,80)
		reButton.backgroundColor = UIColor.greenColor();
		reButton.layer.masksToBounds = true
		reButton.setTitle("Restart", forState: UIControlState.Normal)
		reButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
		reButton.titleLabel?.font = UIFont.systemFontOfSize(CGFloat(30))
		reButton.layer.cornerRadius = 30.0
		reButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height - 100)
		reButton.addTarget(self, action: "restartUpInside:", forControlEvents: .TouchUpInside)
		reButton.addTarget(self, action: "restartOnDown:", forControlEvents: .TouchDown)
		reButton.addTarget(self, action: "restartUpOutside:", forControlEvents: .TouchUpOutside)
		reButton.hidden = true
		self.view.addSubview(reButton);
		
		
		//中止ラベル
		quitLabel = UILabel(frame: CGRectMake(0, 0, 300, 120))
		quitLabel.backgroundColor = UIColor.blackColor()
		quitLabel.layer.masksToBounds = true
		quitLabel.text = "Quit"
		quitLabel.font = UIFont.systemFontOfSize(CGFloat(100))
		quitLabel.textColor = UIColor.whiteColor()
		quitLabel.shadowColor = UIColor.grayColor()
		quitLabel.textAlignment = NSTextAlignment.Center
		quitLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 120)
		quitLabel.hidden = true
		self.view.addSubview(quitLabel)
		
		//フィニッシュラベル
		finishLabel = UILabel(frame: CGRectMake(0, 0, 300, 120))
		finishLabel.backgroundColor = UIColor.blackColor()
		finishLabel.layer.masksToBounds = true
		finishLabel.text = "Finish"
		finishLabel.font = UIFont.systemFontOfSize(CGFloat(100))
		finishLabel.textColor = UIColor.whiteColor()
		finishLabel.shadowColor = UIColor.grayColor()
		finishLabel.textAlignment = NSTextAlignment.Center
		finishLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 120)
		finishLabel.hidden = true
		self.view.addSubview(finishLabel)
	
		//記録テキストフィールド
		recordText = UITextView(frame: CGRect(x: 100, y: 200, width: self.view.frame.width - 200, height: 300))
		recordText.backgroundColor = UIColor.blackColor()
		recordText.textColor = UIColor.whiteColor()
		recordText.textAlignment = NSTextAlignment.Left
		recordText.editable = false
		recordString = ""
		recordText.text = recordString
		recordText.font = UIFont.systemFontOfSize(CGFloat(25))
		recordText.hidden = true
		self.view.addSubview(recordText)
		
		
		UIView.animateWithDuration(0.3,
			animations: { () -> Void in
				self.numButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
				self.quitButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
			})
			{ (Bool) -> Void in
		}

		
		
		self.view.backgroundColor = UIColor.blackColor()
		
	}
	
	
	//ランダムな位置を獲得
	func randomPosition() -> CGPoint{
		var rp = CGPoint()
		var w = self.view.frame.width
		var h = self.view.frame.height
		
		rp.x = w - 120 ; rp.y = h - 120
		rp.x = rp.x * CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + 80
		rp.y = rp.y * CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + 80
		
		return rp
	}
	
	
	//数字ボタンを押す
	func onDownButton(sender: UIButton){
		
		self.numButton.backgroundColor = UIColor.greenColor()
		UIView.animateWithDuration(0.1,
			
			animations: { () -> Void in
				self.numButton.transform = CGAffineTransformMakeScale(1.6, 1.6)
				
			})
			{ (Bool) -> Void in
				
		}
	}
	
	
	//数字ボタンを離す
	func onUpButton(sender: UIButton){
		
		//数字が0の時にスタート
		if numCount == 0 {
			timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
		}
		
		UIView.animateWithDuration(0.3,
			animations: { () -> Void in
				
				self.numButton.transform = CGAffineTransformMakeScale(0.01, 0.01)
				
			})
			{ (Bool) -> Void in
				
				self.numCount++
				
				if self.numCount == 11 {
					self.numCount = 0
					self.recordedTime.append(self.cnt)
					self.numButton.hidden = true
					self.numButton.setTitle("\(self.numCount)", forState: UIControlState.Normal)
					self.numButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
					self.timer.invalidate()
					self.finishLabel.hidden = false
					self.reButton.hidden = false
					
					var list = self.recordedTime.sorted( { return $0 < $1 } )
					self.recordString = ""
					for var i = 1; i <= list.count && i <= 10; i++ {
						switch i {
						case 1:		self.recordString = self.recordString + "".stringByAppendingFormat(" 1st\t:\t%4.2f", list[i-1]) + "s\n"
						case 2:		self.recordString = self.recordString + "".stringByAppendingFormat("2nd\t:\t%4.2f", list[i-1]) + "s\n"
						case 3:		self.recordString = self.recordString + "".stringByAppendingFormat(" 3rd\t:\t%4.2f", list[i-1]) + "s\n"
						case 10:	self.recordString = self.recordString + "".stringByAppendingFormat("10th:\t%4.2f", list[i-1]) + "s\n"
						default:	self.recordString = self.recordString + "".stringByAppendingFormat("%2dth\t:\t%4.2f",i, list[i-1]) + "s\n"
						}
						
					}
					self.recordText.text = self.recordString
					self.recordText.hidden = false
					
					
					UIView.animateWithDuration(0.3,
						animations: { () -> Void in
							self.quitButton.transform = CGAffineTransformMakeScale(0.01, 0.01)
							self.reButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
					})
					
				}else{
					
					self.numButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
					
				}
				
				self.myAudioPlayer.play()
				self.numButton.backgroundColor = UIColor.blueColor();
				self.numButton.setTitle("\(self.numCount)", forState: UIControlState.Normal)
				self.numButton.layer.position = CGPoint(x: self.randomPosition().x, y: self.randomPosition().y)
				
			}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	//時間管理
	func onUpdate(timer : NSTimer){
		
		cnt += 0.01
		let str = "Time : ".stringByAppendingFormat("%4.2f",cnt) + "s"
		tmLabel.text = str
		
	}
	
	//リスタート
	func restartUpInside(sender: UIButton) {
		
		UIView.animateWithDuration(0.3,
			
			animations: { () -> Void in
				sender.transform = CGAffineTransformMakeScale(0.001, 0.001)
			})
			{ (Bool) -> Void in
		}
	
		cnt = 0
		finishLabel.hidden = true
		quitLabel.hidden = true
		numButton.hidden = false
		tmLabel.text = "Time : 0.00s"
		
		
		
		
		recordText.hidden = true
		numButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
		
		UIView.animateWithDuration(0.3,
			animations: { () -> Void in
				self.quitButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
				self.numButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
			})
			{ (Bool) -> Void in
		}
		
	}
	
	//リスタートボタンポップ
	func restartOnDown(sender: UIButton) {
		
		UIView.animateWithDuration(0.3,
			animations: { () -> Void in
				sender.transform = CGAffineTransformMakeScale(1.1, 1.1)
			})
			{ (Bool) -> Void in
			}
	}
	
	//リスタートしない
	func restartUpOutside(sender: UIButton) {
		
		UIView.animateWithDuration(0.3,
			animations: { () -> Void in
				sender.transform = CGAffineTransformMakeScale(1.0, 1.0)
			})
			{ (Bool) -> Void in
		}
	}
	
	//中止ボタンをタップ
	func quitTouched(sender : UIButton) {
		if (timer? != nil) && timer.valid {
			
			UIView.animateWithDuration(0.3,
				animations: { () -> Void in
					sender.transform = CGAffineTransformMakeScale(0.01, 0.01)
					self.numButton.transform = CGAffineTransformMakeScale(0.01, 0.01)
					self.reButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
				})
				{ (Bool) -> Void in
					
					self.tmLabel.text = "No Record"
					self.numCount = 0
					self.numButton.setTitle("\(self.numCount)", forState: UIControlState.Normal)
					self.numButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height/2)
					self.numButton.hidden = true
					self.timer.invalidate()
					self.recordText.hidden = false
					self.quitLabel.hidden = false
					self.reButton.hidden = false
			}
		}
	}
}