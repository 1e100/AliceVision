// This file is part of the AliceVision project.
// Copyright (c) 2022 AliceVision contributors.
// Copyright (c) 2012 openMVG contributors.
// This Source Code Form is subject to the terms of the Mozilla Public License,
// v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

#include <aliceVision/types.hpp>

#include <iosfwd>
#include <string>

namespace aliceVision {
namespace matchingImageCollection {

/**
 * @Brief load pairs from file
 * File format is reference matchImg1 matchImage2 ...\n
 * @param sFileName input file path to load
 * @param pairs the output set of pairs
 * @return false if a problem is detected in the file
*/
bool loadPairsFromFile(const std::string& sFileName, PairSet& pairs);

/**
 * @Brief Save pairs to file
 * File format is reference matchImg1 matchImage2 ...\n
 * @param sFileName input file path to save
 * @param pairs the input set of pairs
 * @return false if a problem is detected in the file
*/
bool savePairsToFile(const std::string& sFileName, const PairSet& pairs);

}  // namespace matchingImageCollection
}  // namespace aliceVision
