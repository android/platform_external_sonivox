/*
 * Copyright (C) 2020 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __SONIVOX_TEST_ENVIRONMENT_H__
#define __SONIVOX_TEST_ENVIRONMENT_H__

#include <gtest/gtest.h>

#include <getopt.h>

using namespace std;

class SonivoxTestEnvironment : public::testing::Environment {
  public:
    SonivoxTestEnvironment() : res("/data/local/tmp/"), deleteOutput(true){}

    // Parses the command line arguments
    int initFromOptions(int argc, char **argv);

    void setRes(const char *_res) { res = _res; }

    const string getRes() const { return res; }

    bool cleanUp() const { return deleteOutput; }

  private:
    string res;
    bool deleteOutput;
};

int SonivoxTestEnvironment::initFromOptions(int argc, char **argv) {
    static struct option options[] = {{"res", required_argument, 0, 'P'},
                                      {"cleanUp", optional_argument, 0, 'C'},
                                      {0, 0, 0, 0}};

    while (true) {
        int index = 0;
        int c = getopt_long(argc, argv, "P:C:", options, &index);
        if (c == -1) {
            break;
        }

        switch (c) {
            case 'P': {
                setRes(optarg);
                break;
            }
            case 'C':
                if (!strcmp(optarg, "false")) {
                    deleteOutput = false;
                }
                break;
            default:
                break;
        }
    }

    if (optind < argc) {
        fprintf(stderr,
                "unrecognized option: %s\n\n"
                "usage: %s <gtest options> <test options>\n\n"
                "test options are:\n\n"
                "-P, --path: Resource files directory location\n"
                "-C, default:true. Delete output file after test completes\n",
                argv[optind ?: 1], argv[0]);
        return 2;
    }
    return 0;
}

#endif  // __SONIVOX_TEST_ENVIRONMENT_H__
