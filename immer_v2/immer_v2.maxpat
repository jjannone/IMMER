{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 9,
      "minor": 1,
      "revision": 4,
      "architecture": "x64",
      "modernui": 1
    },
    "classnamespace": "box",
    "rect": [
      -704.0,
      -916.0,
      1430.0,
      820.0
    ],
    "boxes": [
      {
        "box": {
          "bgmode": 0,
          "border": 0,
          "clickthrough": 0,
          "enablehscroll": 0,
          "enablevscroll": 0,
          "id": "obj-6",
          "lockeddragscroll": 0,
          "lockedsize": 0,
          "maxclass": "bpatcher",
          "name": "n4m.monitor.maxpat",
          "numinlets": 1,
          "numoutlets": 1,
          "offset": [
            0.0,
            0.0
          ],
          "outlettype": [
            "bang"
          ],
          "patching_rect": [
            938.0,
            442.0,
            400.0,
            220.0
          ],
          "viewvisibility": 1
        }
      },
      {
        "box": {
          "fontface": 1,
          "fontsize": 16.0,
          "id": "obj-title",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            10.0,
            490.0,
            24.0
          ],
          "text": "IMMER v2 \u2014 Improvised Movement+Music Ensemble (web-driven score, LAN + cloud relay)"
        }
      },
      {
        "box": {
          "fontsize": 11.0,
          "id": "obj-subtitle",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            36.0,
            538.0,
            19.0
          ],
          "text": "Performers open the URL below on phones/laptops on the same wifi, enter a name, then drive their own role."
        }
      },
      {
        "box": {
          "fontface": 1,
          "fontsize": 12.0,
          "id": "obj-hdr-config",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            70.0,
            470.0,
            20.0
          ],
          "text": "\u2500\u2500 CONFIG \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
        }
      },
      {
        "box": {
          "id": "obj-lbl-port",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            96.0,
            90.0,
            20.0
          ],
          "text": "Port"
        }
      },
      {
        "box": {
          "id": "obj-num-port",
          "maxclass": "number",
          "maximum": 65535,
          "minimum": 1024,
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            120.0,
            96.0,
            70.0,
            22.0
          ]
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-msg-setport",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            200.0,
            96.0,
            100.0,
            22.0
          ],
          "text": "setport $1"
        }
      },
      {
        "box": {
          "id": "obj-lbl-dur",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            124.0,
            90.0,
            20.0
          ],
          "text": "Duration (min)"
        }
      },
      {
        "box": {
          "id": "obj-num-dur",
          "maxclass": "number",
          "maximum": 240,
          "minimum": 1,
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            120.0,
            124.0,
            70.0,
            22.0
          ]
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-msg-setdur",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            200.0,
            124.0,
            130.0,
            22.0
          ],
          "text": "setduration $1"
        }
      },
      {
        "box": {
          "id": "obj-lbl-solo",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            152.0,
            90.0,
            20.0
          ],
          "text": "Solo hold (sec)"
        }
      },
      {
        "box": {
          "id": "obj-num-solo",
          "maxclass": "number",
          "maximum": 600,
          "minimum": 1,
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            120.0,
            152.0,
            70.0,
            22.0
          ]
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-msg-setsolo",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            200.0,
            152.0,
            130.0,
            22.0
          ],
          "text": "setsolohold $1"
        }
      },
      {
        "box": {
          "id": "obj-lbl-countin",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            360.0,
            152.0,
            90.0,
            20.0
          ],
          "text": "Count-in (sec)"
        }
      },
      {
        "box": {
          "id": "obj-num-countin",
          "maxclass": "number",
          "maximum": 60,
          "minimum": 0,
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            460.0,
            152.0,
            50.0,
            22.0
          ]
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-msg-setcountin",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            520.0,
            152.0,
            110.0,
            22.0
          ],
          "text": "setcountin $1"
        }
      },
      {
        "box": {
          "fontface": 1,
          "fontsize": 12.0,
          "id": "obj-hdr-trans",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            188.0,
            600.0,
            20.0
          ],
          "text": "\u2500\u2500 TRANSPORT \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
        }
      },
      {
        "box": {
          "bgcolor": [
            0.4,
            0.85,
            0.4,
            1.0
          ],
          "id": "obj-btn-start",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            20.0,
            214.0,
            30.0,
            30.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-lbl-start",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            54.0,
            218.0,
            60.0,
            20.0
          ],
          "text": "START"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-msg-start",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            20.0,
            265.0,
            50.0,
            22.0
          ],
          "text": "start"
        }
      },
      {
        "box": {
          "id": "obj-btn-stop",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            120.0,
            214.0,
            30.0,
            30.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-lbl-stop",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            154.0,
            218.0,
            60.0,
            20.0
          ],
          "text": "STOP"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-msg-stop",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            120.0,
            265.0,
            50.0,
            22.0
          ],
          "text": "stop"
        }
      },
      {
        "box": {
          "id": "obj-btn-reset",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            220.0,
            214.0,
            30.0,
            30.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-lbl-reset",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            254.0,
            218.0,
            60.0,
            20.0
          ],
          "text": "RESET"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-msg-reset",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            220.0,
            265.0,
            50.0,
            22.0
          ],
          "text": "reset"
        }
      },
      {
        "box": {
          "bgcolor": [
            0.85,
            0.4,
            0.4,
            1.0
          ],
          "id": "obj-btn-clear",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            320.0,
            214.0,
            30.0,
            30.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-lbl-clear",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            354.0,
            218.0,
            100.0,
            20.0
          ],
          "text": "CLEAR (kick all)"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-msg-clear",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            320.0,
            265.0,
            50.0,
            22.0
          ],
          "text": "clear"
        }
      },
      {
        "box": {
          "fontface": 1,
          "fontsize": 12.0,
          "id": "obj-hdr-state",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            290.0,
            600.0,
            20.0
          ],
          "text": "\u2500\u2500 LIVE \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
        }
      },
      {
        "box": {
          "id": "obj-lbl-url",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            316.0,
            90.0,
            20.0
          ],
          "text": "Server URL"
        }
      },
      {
        "box": {
          "fontface": 1,
          "fontsize": 13.0,
          "id": "obj-url",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            120.0,
            316.0,
            400.0,
            21.0
          ],
          "text": "http://192.168.68.59:8080/",
          "textcolor": [
            0.3,
            0.7,
            1.0,
            1.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-lbl-status",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            344.0,
            90.0,
            20.0
          ],
          "text": "Status"
        }
      },
      {
        "box": {
          "id": "obj-status",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            120.0,
            344.0,
            217.0,
            20.0
          ],
          "text": "Started \u2014 1200s, 3 performers"
        }
      },
      {
        "box": {
          "id": "obj-lbl-count",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            380.0,
            110.0,
            20.0
          ],
          "text": "Countdown (sec)"
        }
      },
      {
        "box": {
          "fontsize": 22.0,
          "id": "obj-countdown",
          "maxclass": "number",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            130.0,
            376.0,
            120.0,
            33.0
          ]
        }
      },
      {
        "box": {
          "coldef": [
            [
              0,
              28,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ],
            [
              1,
              110,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ],
            [
              2,
              60,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ],
            [
              3,
              56,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ],
            [
              4,
              56,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ],
            [
              5,
              56,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ],
            [
              6,
              56,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ],
            [
              7,
              56,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ],
            [
              8,
              46,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              1,
              0.0,
              0.0,
              0.0,
              1.0,
              -1,
              -1,
              -1
            ]
          ],
          "cols": 9,
          "fontface": 0,
          "fontname": "Arial",
          "fontsize": 12.0,
          "id": "obj-cellblock",
          "maxclass": "jit.cellblock",
          "numinlets": 2,
          "numoutlets": 4,
          "outlettype": [
            "list",
            "",
            "",
            ""
          ],
          "patching_rect": [
            20.0,
            620.0,
            600.0,
            280.0
          ],
          "rows": 4
        }
      },
      {
        "box": {
          "fontface": 1,
          "fontsize": 12.0,
          "hidden": 1,
          "id": "obj-hdr-server",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            700.0,
            70.0,
            460.0,
            20.0
          ],
          "text": "\u2500\u2500 SERVER (right-click node.script \u2192 Debug to open Chrome DevTools) \u2500\u2500"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-loadbang",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "patching_rect": [
            700.0,
            96.0,
            60.0,
            22.0
          ],
          "text": "loadbang"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-defaults",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 6,
          "outlettype": [
            "bang",
            "bang",
            "bang",
            "bang",
            "bang",
            "bang"
          ],
          "patching_rect": [
            700.0,
            124.0,
            130.0,
            22.0
          ],
          "text": "t b b b b b b"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-def-port",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            700.0,
            156.0,
            50.0,
            22.0
          ],
          "text": "8081"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-def-dur",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            760.0,
            156.0,
            50.0,
            22.0
          ],
          "text": "20"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-def-solo",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            820.0,
            156.0,
            50.0,
            22.0
          ],
          "text": "15"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-def-countin",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            880.0,
            156.0,
            50.0,
            22.0
          ],
          "text": "10"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-nodescript",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            ""
          ],
          "patching_rect": [
            700.0,
            290.0,
            320.0,
            22.0
          ],
          "saved_object_attributes": {
            "autostart": 1,
            "defer": 0,
            "node_bin_path": "",
            "npm_bin_path": "",
            "watch": 1
          },
          "text": "node.script server.js @autostart 1 @watch 1 @restart 1",
          "textfile": {
            "filename": "server.js",
            "flags": 0,
            "embed": 0,
            "autowatch": 1
          }
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-route-top",
          "maxclass": "newobj",
          "numinlets": 9,
          "numoutlets": 10,
          "outlettype": [
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
          ],
          "patching_rect": [
            700.0,
            326.0,
            600.0,
            22.0
          ],
          "text": "route performer roster countdown status url coverage complete cell cloud"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-status-pre",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            880.0,
            384.0,
            100.0,
            22.0
          ],
          "text": "prepend set"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-url-pre",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            980.0,
            360.0,
            100.0,
            22.0
          ],
          "text": "prepend set"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-print-complete",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1180.0,
            360.0,
            130.0,
            22.0
          ],
          "text": "print COMPLETE"
        }
      },
      {
        "box": {
          "hidden": 1,
          "id": "obj-coverage-print",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            1080.0,
            360.0,
            103.0,
            22.0
          ],
          "text": "print COVERAGE"
        }
      },
      {
        "box": {
          "bgcolor": [
            0.95,
            0.95,
            0.92,
            1.0
          ],
          "fontsize": 11.0,
          "id": "obj-notes",
          "linecount": 24,
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            700.0,
            420.0,
            220.0,
            301.0
          ],
          "text": "FIRST-TIME SETUP\n  1. open Terminal in this folder\n  2. run:  npm install\n     (installs ws \u2014 needed once)\n  3. Max:  the patch auto-starts the server.\n\nIF YOU CHANGE server.js\n  \u2022 @watch 1 reloads it automatically.\n  \u2022 or click START \u2192 STOP on the patch.\n\nDEBUG\n  \u2022 right-click [node.script] \u2192 Debug\n    opens Chrome DevTools attached to the\n    server (set breakpoints, eval, etc.).\n  \u2022 the SERVER print object (top right)\n    streams every routed message to the\n    Max console.\n\nPERFORMERS\n  \u2022 visit the Server URL from any device\n    on the same wifi.\n  \u2022 enter name \u2192 join.\n  \u2022 when conductor hits START, role buttons\n    activate.",
          "textcolor": [
            0.0,
            0.0,
            0.0,
            1.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-route-cloud",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 4,
          "outlettype": [
            "",
            "",
            "",
            ""
          ],
          "patching_rect": [
            700.0,
            360.0,
            240.0,
            22.0
          ],
          "hidden": 1,
          "text": "route connected status performurl"
        }
      },
      {
        "box": {
          "id": "obj-cloud-conn",
          "maxclass": "toggle",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "int"
          ],
          "patching_rect": [
            160.0,
            530.0,
            24.0,
            24.0
          ],
          "parameter_enable": 0
        }
      },
      {
        "box": {
          "id": "obj-lbl-cloudconn",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            532.0,
            130.0,
            20.0
          ],
          "text": "Cloud connected"
        }
      },
      {
        "box": {
          "id": "obj-cloudstatus-pre",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            820.0,
            360.0,
            90.0,
            22.0
          ],
          "hidden": 1,
          "text": "prepend set"
        }
      },
      {
        "box": {
          "id": "obj-cloudstatus",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            220.0,
            558.0,
            400.0,
            20.0
          ],
          "text": "(cloud bridge idle)"
        }
      },
      {
        "box": {
          "id": "obj-lbl-cloudstatus",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            558.0,
            200.0,
            20.0
          ],
          "text": "Cloud status"
        }
      },
      {
        "box": {
          "id": "obj-cloudurl-pre",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            930.0,
            360.0,
            90.0,
            22.0
          ],
          "hidden": 1,
          "text": "prepend set"
        }
      },
      {
        "box": {
          "id": "obj-cloud-performurl",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            220.0,
            586.0,
            600.0,
            20.0
          ],
          "text": "(set Cloud URL + Site base, then Cloud connect)"
        }
      },
      {
        "box": {
          "id": "obj-lbl-cloudperformurl",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            586.0,
            200.0,
            20.0
          ],
          "text": "Performer URL"
        }
      },
      {
        "box": {
          "id": "obj-hdr-cloud",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            420.0,
            600.0,
            20.0
          ],
          "text": "\u2500\u2500 CLOUD (optional internet relay for remote performers) \u2500\u2500"
        }
      },
      {
        "box": {
          "id": "obj-lbl-piece",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            446.0,
            60.0,
            20.0
          ],
          "text": "Piece"
        }
      },
      {
        "box": {
          "id": "obj-te-piece",
          "maxclass": "textedit",
          "numinlets": 1,
          "numoutlets": 4,
          "outlettype": [
            "",
            "int",
            "",
            ""
          ],
          "patching_rect": [
            90.0,
            446.0,
            120.0,
            22.0
          ],
          "parameter_enable": 0,
          "text": "immer_v2"
        }
      },
      {
        "box": {
          "id": "obj-msg-setpiece",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            1140.0,
            446.0,
            140.0,
            22.0
          ],
          "hidden": 1,
          "text": "setpiece $1"
        }
      },
      {
        "box": {
          "id": "obj-lbl-room",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            230.0,
            446.0,
            60.0,
            20.0
          ],
          "text": "Room"
        }
      },
      {
        "box": {
          "id": "obj-te-room",
          "maxclass": "textedit",
          "numinlets": 1,
          "numoutlets": 4,
          "outlettype": [
            "",
            "int",
            "",
            ""
          ],
          "patching_rect": [
            300.0,
            446.0,
            120.0,
            22.0
          ],
          "parameter_enable": 0,
          "text": "main"
        }
      },
      {
        "box": {
          "id": "obj-msg-setroom",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            1140.0,
            472.0,
            140.0,
            22.0
          ],
          "hidden": 1,
          "text": "setroom $1"
        }
      },
      {
        "box": {
          "id": "obj-lbl-cloudurl",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            474.0,
            90.0,
            20.0
          ],
          "text": "Cloud URL"
        }
      },
      {
        "box": {
          "id": "obj-te-cloudurl",
          "maxclass": "textedit",
          "numinlets": 1,
          "numoutlets": 4,
          "outlettype": [
            "",
            "int",
            "",
            ""
          ],
          "patching_rect": [
            120.0,
            474.0,
            500.0,
            22.0
          ],
          "parameter_enable": 0,
          "text": "wss://mu-relay.jannone-544.workers.dev"
        }
      },
      {
        "box": {
          "id": "obj-msg-setcloudurl",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            1140.0,
            498.0,
            200.0,
            22.0
          ],
          "hidden": 1,
          "text": "setcloudurl $1"
        }
      },
      {
        "box": {
          "id": "obj-lbl-sitebase",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            20.0,
            502.0,
            90.0,
            20.0
          ],
          "text": "Site base"
        }
      },
      {
        "box": {
          "id": "obj-te-sitebase",
          "maxclass": "textedit",
          "numinlets": 1,
          "numoutlets": 4,
          "outlettype": [
            "",
            "int",
            "",
            ""
          ],
          "patching_rect": [
            120.0,
            502.0,
            500.0,
            22.0
          ],
          "parameter_enable": 0,
          "text": ""
        }
      },
      {
        "box": {
          "id": "obj-msg-setsitebase",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            1140.0,
            524.0,
            220.0,
            22.0
          ],
          "hidden": 1,
          "text": "setsitebase $1"
        }
      },
      {
        "box": {
          "id": "obj-btn-cloudon",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "patching_rect": [
            200.0,
            528.0,
            24.0,
            24.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-lbl-cloudon",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            228.0,
            532.0,
            90.0,
            20.0
          ],
          "text": "Cloud connect"
        }
      },
      {
        "box": {
          "id": "obj-msg-cloudon",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            1140.0,
            550.0,
            80.0,
            22.0
          ],
          "hidden": 1,
          "text": "cloudon"
        }
      },
      {
        "box": {
          "id": "obj-btn-cloudoff",
          "maxclass": "button",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "patching_rect": [
            340.0,
            528.0,
            24.0,
            24.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-lbl-cloudoff",
          "maxclass": "comment",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            368.0,
            532.0,
            110.0,
            20.0
          ],
          "text": "Cloud disconnect"
        }
      },
      {
        "box": {
          "id": "obj-msg-cloudoff",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            1140.0,
            576.0,
            80.0,
            22.0
          ],
          "hidden": 1,
          "text": "cloudoff"
        }
      },
      {
        "box": {
          "id": "obj-def-piece",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            880.0,
            152.0,
            140.0,
            22.0
          ],
          "hidden": 1,
          "text": "setpiece immer_v2"
        }
      },
      {
        "box": {
          "id": "obj-def-room",
          "maxclass": "message",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            880.0,
            178.0,
            140.0,
            22.0
          ],
          "hidden": 1,
          "text": "setroom main"
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "destination": [
            "obj-msg-clear",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-btn-clear",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-reset",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-btn-reset",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-start",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-btn-start",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-stop",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-btn-stop",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-num-countin",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-def-countin",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-num-dur",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-def-dur",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-num-port",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-def-port",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-num-solo",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-def-solo",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-def-countin",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-defaults",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-def-dur",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-defaults",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-def-port",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-defaults",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-def-solo",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-defaults",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-defaults",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-loadbang",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-clear",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-reset",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-setcountin",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-setdur",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-setport",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-setsolo",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-start",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-stop",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-6",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-nodescript",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-route-top",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-nodescript",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-setcountin",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-num-countin",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-setdur",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-num-dur",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-setport",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-num-port",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-setsolo",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-num-solo",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-cellblock",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-top",
            7
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-countdown",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-top",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-coverage-print",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-top",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-print-complete",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-top",
            6
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-status-pre",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-top",
            3
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-url-pre",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-top",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-status",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-status-pre",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-url",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-url-pre",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-route-cloud",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-top",
            8
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-cloud-conn",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-cloud",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-cloudstatus-pre",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-cloud",
            1
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-cloudstatus",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-cloudstatus-pre",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-cloudurl-pre",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-route-cloud",
            2
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-cloud-performurl",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-cloudurl-pre",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-setpiece",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-te-piece",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-setpiece",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-setroom",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-te-room",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-setroom",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-setcloudurl",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-te-cloudurl",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-setcloudurl",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-setsitebase",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-te-sitebase",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-setsitebase",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-cloudon",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-btn-cloudon",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-cloudon",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-msg-cloudoff",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-btn-cloudoff",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-msg-cloudoff",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-def-piece",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-defaults",
            4
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-def-room",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-defaults",
            5
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-def-piece",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-nodescript",
            0
          ],
          "hidden": 1,
          "source": [
            "obj-def-room",
            0
          ]
        }
      }
    ],
    "autosave": 0
  }
}