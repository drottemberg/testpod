//
//  String.swift
//  OurCartSDK
//
//  Created by Damien Rottemberg on 9/27/17.
//  Copyright © 2017 OurCart. All rights reserved.
//

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.index(start, offsetBy: r.upperBound-r.lowerBound)
        return self[Range(start ..< end)]
    }
    
    func toDigit() -> String{
        return String(self.filter { "01234567890".characters.contains($0) })
    }
    
    func isValidEmailAddress() -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
        } catch {
            returnValue = false
        }
        
        return  returnValue
    }
    
    func trim()->String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func toDate(format:String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from:self)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from:components)!
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
    
    public static func isNilOrEmpty(string: String?) -> Bool {
        
        switch string?.trimmingCharacters(in:NSCharacterSet.whitespaces) {
        case .some(let nonNilString):
            return nonNilString.isEmpty
        default:
            return true
        }
    }
    
    func localize() -> String{
        return NSLocalizedString(self, comment: "")
    }
    
    
    func hash() -> String {
        var data = self.data(using: .utf8)
        data = data!.md5()
        return data!.toHexString()
    }
       func capturedGroups(withRegex pattern: String) -> [String] {
            var results = [String]()
            
            var regex: NSRegularExpression
            do {
                regex = try NSRegularExpression(pattern: pattern, options: [])
            } catch {
                return results
            }
            
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
            
            guard let match = matches.first else { return results }
            
            let lastRangeIndex = match.numberOfRanges - 1
            guard lastRangeIndex >= 1 else { return results }
            
            for i in 1...lastRangeIndex {
                let capturedGroupIndex = match.rangeAt(i)
                let matchedString = (self as NSString).substring(with: capturedGroupIndex)
                results.append(matchedString)
            }
            
            return results
        }
    
}

extension NSAttributedString{
    
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
    
}
