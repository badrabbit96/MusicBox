
import UIKit
import AVFoundation
import AVKit

class PlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    
    @IBOutlet weak var thumbNailImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var seekLoadingLabel: UILabel!

    var playList: NSMutableArray = NSMutableArray()
    var timer: Timer?
    var index: Int = Int()
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var songs:[String] =  []
    
    var blur_counter : Int = 0
    
    @IBOutlet weak var song_author: UILabel!

    @IBOutlet weak var image_cover: UIImageView!
    
    @IBOutlet weak var song_title_label: UILabel!
    
    @IBOutlet weak var music_list: UITableView!
    
    @IBOutlet weak var background_image: UIImageView!
    
    @IBAction func libray_button(_ sender: UIButton) {
        
       
        if(music_list.isHidden == false){
            music_list.isHidden = true
        }
        else if (music_list.isHidden == true){
            music_list.isHidden = false
        }
        
    }
    
   
   
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isPaused = false
        playButton.setImage(UIImage(named:"pause_grey"), for: .normal)
        self.playList.add("http://stacja-meteo.pl/mp3/Dawid%20Podsiadlo%20-%20Nie%20Ma%20Fal.mp3")
        self.playList.add("http://stacja-meteo.pl/mp3/Post%20Malone%20-%20Congratulations.mp3")
        self.playList.add("http://stacja-meteo.pl/mp3/The%20Chainsmokers%20&%20Aazar%20%E2%80%93%20Siren.mp3")
        self.playList.add("http://stacja-meteo.pl/mp3/Khalid%20-%20Better.mp3")
        self.playList.add("http://stacja-meteo.pl/mp3/Pawel%20Kukiz%20-%20Na%20falochronie.mp3")
        self.playList.add("http://stacja-meteo.pl/mp3/Dzem-%20Wehikul%20czasu.mp3")
        self.play(url: URL(string:(playList[self.index] as! String))!)
        
        music_list.isHidden = true
        gettingSongName()
        
        self.setupTimer()
        
        image_cover.layer.shadowColor = UIColor.black.cgColor
        image_cover.layer.shadowOpacity = 1
        image_cover.layer.shadowOffset = CGSize.zero
        image_cover.layer.shadowRadius = 30
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeActionRight(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeActionLeft(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)

    }
    
    @objc func swipeActionRight(swipe:UISwipeGestureRecognizer)
    {
        self.prevTrack()
    }
    
    @objc func swipeActionLeft(swipe:UISwipeGestureRecognizer)
    {
        self.nextTrack()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = songs[indexPath.row]
        cell.contentView.backgroundColor = UIColor.darkGray
        cell.textLabel?.textColor = UIColor.white
        
        tableView.layer.borderWidth = 2.0;
        tableView.layer.cornerRadius = 5.0;
        tableView.layer.borderColor = UIColor.lightGray.cgColor;

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do
        {
            let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
            selectedCell.contentView.backgroundColor = UIColor.gray
            
            let audioPath = "http://stacja-meteo.pl/mp3/" + songs[indexPath.row] + ".mp3"
            let audioPathFinal = audioPath.replacingOccurrences(of: " ", with: "%20")
            
            self.play(url: URL(string:(audioPathFinal))!)
            self.setupTimer()
            playButton.setImage(UIImage(named:"pause_grey"), for: .normal)
            
            
        }
        catch
        {
            print("ERROR")
        }
    }
    
  
    
    func play(url:URL) {
        self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        if #available(iOS 10.0, *) {
            self.avPlayer.automaticallyWaitsToMinimizeStalling = false
        }
        avPlayer!.volume = 1.0
        avPlayer.play()
      
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.metadata as! [AVMetadataItem]
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
        
        for item in metadataList {
            
            guard let key = item.commonKey?.rawValue, let value = item.value else{
                continue
            }
            
            switch key {
            case "title" : song_title_label.text = value as? String
            case "artist": song_author.text = value as? String
            //case "artwork" where value is Data : image_cover.image = UIImage(data: value as! Data)
            
            case "artwork": do {
                if let audioImage = UIImage(data: value as! Data) {
                    
                //    let size = CGSize(width: 0, height: 0)

                    if (audioImage != nil){
                        image_cover.image = audioImage
                        background_image.image = audioImage
                        
                        if(blur_counter == 0){
                        background_image.addSubview(blurEffectView)
                        }
                        blur_counter = blur_counter + 1
                        
                        print("jest obrazek")
                    }
                    else{
                        print("brak")
                    }
                    
                    
                }
              
                }
            
            default:
                continue
            }
        }
        
    }
  

    override func viewWillDisappear( _ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.avPlayer = nil
        self.timer?.invalidate()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    
    func gettingSongName()
    {
        do
        {
            for song in playList
            {
                var mySong = song
                //  print (mySong)
                if (mySong as AnyObject).contains(".mp3")
                {
                    //print (mySong)
                    let findString = (mySong as AnyObject).components(separatedBy: "/")
                    //print (mySong)
                    mySong = (findString[findString.count-1])
                    // print (mySong)
                    mySong = (mySong as AnyObject).replacingOccurrences(of: "%20", with: " ")
                    mySong = (mySong as AnyObject).replacingOccurrences(of: "%5B", with: "")
                    mySong = (mySong as AnyObject).replacingOccurrences(of: "%5D", with: "")
                    mySong = (mySong as AnyObject).replacingOccurrences(of: "%C5%82", with: "ł")
                    mySong = (mySong as AnyObject).replacingOccurrences(of: ".mp3", with: "")
                    songs.append(mySong as! String)
                    //print(songs)
                }
            }
            
            music_list.reloadData()
        }
        catch
        {
            
        }
        
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            self.togglePlayPause()
        } else {
            // showAlert "upgrade ios version to use this feature"
           
        }
    }
    
    @available(iOS 10.0, *)
    func togglePlayPause() {
        if avPlayer.timeControlStatus == .playing  {
            playButton.setImage(UIImage(named:"play_grey"), for: .normal)
            avPlayer.pause()
            isPaused = true
        } else {
            playButton.setImage(UIImage(named:"pause_grey"), for: .normal)
            avPlayer.play()
            isPaused = false
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        self.nextTrack()
    }
    
    @IBAction func prevButtonClicked(_ sender: Any) {
        self.prevTrack()
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        avPlayer!.seek(to: targetTime)
        if(isPaused == false){
            seekLoadingLabel.alpha = 1
        }
    }
    
    @IBAction func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        if let slider = sender.view as? UISlider {
            if slider.isHighlighted { return }
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            let seconds : Int64 = Int64(value)
            let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
            avPlayer!.seek(to: targetTime)
            if(isPaused == false){
                seekLoadingLabel.alpha = 1
            }
        }
    }
    
    func setupTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(PlayerViewController.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    @objc func didPlayToEnd() {
        self.nextTrack()
    }
    
    @objc func tick(){
        if(avPlayer.currentTime().seconds == 0.0){
            loadingLabel.alpha = 1
        }else{
            loadingLabel.alpha = 0
        }
        
        if(isPaused == false){
            if(avPlayer.rate == 0){
                avPlayer.play()
                seekLoadingLabel.alpha = 1
            }else{
                seekLoadingLabel.alpha = 0
            }
        }
        
        if((avPlayer.currentItem?.asset.duration) != nil){
            let currentTime1 : CMTime = (avPlayer.currentItem?.asset.duration)!
            let seconds1 : Float64 = CMTimeGetSeconds(currentTime1)
            let time1 : Float = Float(seconds1)
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = time1
            let currentTime : CMTime = (self.avPlayer?.currentTime())!
            let seconds : Float64 = CMTimeGetSeconds(currentTime)
            let time : Float = Float(seconds)
            self.playerSlider.value = time
            timeLabel.text =  self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.asset.duration)!)))))
            currentTimeLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.currentTime())!)))))
            
        }else{
            playerSlider.value = 0
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = 0
            timeLabel.text = "Live stream \(self.formatTimeFromSeconds(totalSeconds: Int32(CMTimeGetSeconds((avPlayer.currentItem?.currentTime())!))))"
        }
    }
    
    
    func nextTrack(){
        if(index < playList.count-1){
            index = index + 1
            isPaused = false
            playButton.setImage(UIImage(named:"pause_grey"), for: .normal)
            self.play(url: URL(string:(playList[self.index] as! String))!)
          
            
        }else{
            index = 0
            isPaused = false
            playButton.setImage(UIImage(named:"pause_grey"), for: .normal)
             self.play(url: URL(string:(playList[self.index] as! String))!)
        }
    }
    
    func prevTrack(){
        if(index > 0){
            index = index - 1
            isPaused = false
            playButton.setImage(UIImage(named:"pause_grey"), for: .normal)
             self.play(url: URL(string:(playList[self.index] as! String))!)
            
        }
    }
    
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.avPlayer = nil
            self.timer?.invalidate()
        }
    }
    
}
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}




