// This file is part of the AliceVision project.
// Copyright (c) 2025 AliceVision contributors.
// This Source Code Form is subject to the terms of the Mozilla Public License,
// v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at https://mozilla.org/MPL/2.0/.

#pragma once

#include <aliceVision/sfmData/SfMData.hpp>
#include <aliceVision/camera/Pinhole.hpp>
#include <pxr/usd/usd/stage.h>

namespace aliceVision {
namespace sfmDataIO {

class UsdExporter
{
public:
    UsdExporter(const std::string & filename, double frameRate);

    void createNewCamera(const std::string & cameraName);
    
    void addFrame(const std::string & cameraName, const sfmData::CameraPose & pose, const camera::Pinhole & camera, IndexT frameId);

    void terminate();

private:
    pxr::UsdStageRefPtr _stage;
    IndexT _startTimeCode;
    IndexT _endTimeCode;
};

}  // namespace sfmDataIO
}  // namespace aliceVision
