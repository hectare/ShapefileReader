//
//  ShapefileReaderTests.swift
//  ShapefileReaderTests
//
//  Created by Hectare on 22/8/18.
//

import XCTest
@testable import ShapefileReader

class ShapefileReaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testShapeName() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "lime", withExtension: "shp", subdirectory: "lime") else { return }
        
        do {
            let sr = try ShapefileReader(path: url)
            let expected = url.deletingPathExtension().absoluteString
            XCTAssertEqual(expected, sr.shapeName)
        } catch {
            XCTFail("Could not read shapefile")
        }
    }
    
    func testDBFReader() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "lime", withExtension: "shp", subdirectory: "lime") else { return }
        
        do {
            let sr = try ShapefileReader(path: url)
            guard let dbf = sr.dbf else { return }
            
            XCTAssertEqual(dbf.fileType, 3)
            XCTAssertEqual(dbf.headerLength, 161)
            XCTAssertEqual(dbf.lastUpdate, "2018-08-22")
            
            let expected = ["AREA", "LIME", "PDK", "SEASON"]
            let fields = dbf.fieldNames
            
            XCTAssertEqual(fields, expected)
            
            let p4 = try dbf.recordAtIndex(1)[0] as! String
            XCTAssertEqual(p4, "P4")
            let rate = try dbf.recordAtIndex(1)[1] as! Int
            XCTAssertEqual(rate, 2800)
            let year = try dbf.recordAtIndex(1)[2] as! Int
            XCTAssertEqual(year, 2016)
            let area = try dbf.recordAtIndex(1)[3] as! Int
            XCTAssertEqual(area, 245188)
            
            XCTAssertEqual(dbf.numberOfRecords, 3)
            let allRecordsCount = try dbf.allRecords().count
            XCTAssertEqual(allRecordsCount, 3)
            
            // Attempt to access a non-existent record
            // We use allRecords here, because the *index*
            // of the last record should be allRecords - 1
            XCTAssertThrowsError(try dbf.recordAtIndex(allRecordsCount))
            
            XCTAssertEqual(dbf.recordLengthFromHeader, 18)
            XCTAssertEqual(dbf.recordFormat, "<1s2s4s4s7s")
        } catch {
            XCTFail("DBFReader Error: \(error)")
        }
    }
    
    func testShapes() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "lime", withExtension: "shp", subdirectory: "lime") else { return }
        
        do {
            let sr = try ShapefileReader(path: url)
            
            guard let shp = sr.shp, let dbf = sr.dbf else { return }
            
            // file properties
            let expectedBbox = [115.01108517818956, -27.919564227498576,
                                115.02932540406678, -27.890015075198161]
            let bbox = shp.bbox
            XCTAssertEqual([bbox.x_min, bbox.y_min, bbox.x_max, bbox.y_max], expectedBbox)
            
            let elevation = [0.0, 0.0]
            XCTAssertEqual([shp.elevation.z_min, shp.elevation.z_max], elevation)
            
            XCTAssertEqual(shp.shapeType, .polygon)
            
            XCTAssertEqual(shp.allShapes().count, try dbf.allRecords().count)
            
            // Check 3rd shape properties
            let thirdShape = shp.allShapes()[2]
            XCTAssertEqual(thirdShape.points.count, 151)
            XCTAssertEqual(thirdShape.shapeType, .polygon)
            XCTAssertEqual(thirdShape.parts, [0, 142])
            XCTAssertEqual(thirdShape.partTypes, [])
        } catch {
            XCTFail("Shape Error: \(error)")
        }
        
    }
    
    func testReadTime() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "lime", withExtension: "shp", subdirectory: "lime") else { return }
        measure {
            do {
                let _ = try ShapefileReader(path: url)
            } catch {
                XCTFail("Could not read shapefile")
            }
        }
    }
    
}
