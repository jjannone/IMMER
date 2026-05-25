{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 9,
			"minor" : 0,
			"revision" : 0,
			"architecture" : "x64",
			"modernui" : 1
		}
,
		"classnamespace" : "box",
		"rect" : [ 100.0, 100.0, 1200.0, 820.0 ],
		"gridsize" : [ 15.0, 15.0 ],
		"boxes" : [
			{
				"box" : 				{
					"id" : "obj-title",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 10.0, 600.0, 24.0 ],
					"text" : "IMMER — Improvised Movement+Music Ensemble (web-driven)",
					"fontsize" : 16.0,
					"fontface" : 1
				}
			},
			{
				"box" : 				{
					"id" : "obj-subtitle",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 36.0, 800.0, 20.0 ],
					"text" : "Performers open the URL below on phones/laptops on the same wifi, enter a name, then drive their own role.",
					"fontsize" : 11.0
				}
			},

			{
				"box" : 				{
					"id" : "obj-hdr-config",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 70.0, 600.0, 20.0 ],
					"text" : "── CONFIG ──────────────────────────────────────────────",
					"fontsize" : 12.0,
					"fontface" : 1
				}
			},

			{
				"box" : 				{
					"id" : "obj-lbl-port",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 96.0, 90.0, 20.0 ],
					"text" : "Port"
				}
			},
			{
				"box" : 				{
					"id" : "obj-num-port",
					"maxclass" : "number",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "bang" ],
					"patching_rect" : [ 120.0, 96.0, 70.0, 22.0 ],
					"minimum" : 1024,
					"maximum" : 65535
				}
			},
			{
				"box" : 				{
					"id" : "obj-msg-setport",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 200.0, 96.0, 100.0, 22.0 ],
					"text" : "setport $1"
				}
			},

			{
				"box" : 				{
					"id" : "obj-lbl-dur",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 124.0, 90.0, 20.0 ],
					"text" : "Duration (min)"
				}
			},
			{
				"box" : 				{
					"id" : "obj-num-dur",
					"maxclass" : "number",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "bang" ],
					"patching_rect" : [ 120.0, 124.0, 70.0, 22.0 ],
					"minimum" : 1,
					"maximum" : 240
				}
			},
			{
				"box" : 				{
					"id" : "obj-msg-setdur",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 200.0, 124.0, 130.0, 22.0 ],
					"text" : "setduration $1"
				}
			},

			{
				"box" : 				{
					"id" : "obj-lbl-solo",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 152.0, 90.0, 20.0 ],
					"text" : "Solo hold (sec)"
				}
			},
			{
				"box" : 				{
					"id" : "obj-num-solo",
					"maxclass" : "number",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "bang" ],
					"patching_rect" : [ 120.0, 152.0, 70.0, 22.0 ],
					"minimum" : 1,
					"maximum" : 600
				}
			},
			{
				"box" : 				{
					"id" : "obj-msg-setsolo",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 200.0, 152.0, 130.0, 22.0 ],
					"text" : "setsolohold $1"
				}
			},

			{
				"box" : 				{
					"id" : "obj-hdr-trans",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 188.0, 600.0, 20.0 ],
					"text" : "── TRANSPORT ───────────────────────────────────────────",
					"fontsize" : 12.0,
					"fontface" : 1
				}
			},

			{
				"box" : 				{
					"id" : "obj-btn-start",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 20.0, 214.0, 30.0, 30.0 ],
					"bgcolor" : [ 0.4, 0.85, 0.4, 1.0 ]
				}
			},
			{
				"box" : 				{
					"id" : "obj-lbl-start",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 54.0, 218.0, 60.0, 20.0 ],
					"text" : "START"
				}
			},
			{
				"box" : 				{
					"id" : "obj-msg-start",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 20.0, 250.0, 50.0, 22.0 ],
					"text" : "start"
				}
			},

			{
				"box" : 				{
					"id" : "obj-btn-stop",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 120.0, 214.0, 30.0, 30.0 ]
				}
			},
			{
				"box" : 				{
					"id" : "obj-lbl-stop",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 154.0, 218.0, 60.0, 20.0 ],
					"text" : "STOP"
				}
			},
			{
				"box" : 				{
					"id" : "obj-msg-stop",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 120.0, 250.0, 50.0, 22.0 ],
					"text" : "stop"
				}
			},

			{
				"box" : 				{
					"id" : "obj-btn-reset",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 220.0, 214.0, 30.0, 30.0 ]
				}
			},
			{
				"box" : 				{
					"id" : "obj-lbl-reset",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 254.0, 218.0, 60.0, 20.0 ],
					"text" : "RESET"
				}
			},
			{
				"box" : 				{
					"id" : "obj-msg-reset",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 220.0, 250.0, 50.0, 22.0 ],
					"text" : "reset"
				}
			},

			{
				"box" : 				{
					"id" : "obj-btn-clear",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 320.0, 214.0, 30.0, 30.0 ],
					"bgcolor" : [ 0.85, 0.4, 0.4, 1.0 ]
				}
			},
			{
				"box" : 				{
					"id" : "obj-lbl-clear",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 354.0, 218.0, 100.0, 20.0 ],
					"text" : "CLEAR (kick all)"
				}
			},
			{
				"box" : 				{
					"id" : "obj-msg-clear",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 320.0, 250.0, 50.0, 22.0 ],
					"text" : "clear"
				}
			},

			{
				"box" : 				{
					"id" : "obj-hdr-state",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 290.0, 600.0, 20.0 ],
					"text" : "── LIVE ────────────────────────────────────────────────",
					"fontsize" : 12.0,
					"fontface" : 1
				}
			},

			{
				"box" : 				{
					"id" : "obj-lbl-url",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 316.0, 90.0, 20.0 ],
					"text" : "Server URL"
				}
			},
			{
				"box" : 				{
					"id" : "obj-url",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 120.0, 316.0, 400.0, 22.0 ],
					"text" : "(starts when patch loads)",
					"fontsize" : 13.0,
					"fontface" : 1,
					"textcolor" : [ 0.3, 0.7, 1.0, 1.0 ]
				}
			},

			{
				"box" : 				{
					"id" : "obj-lbl-status",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 344.0, 90.0, 20.0 ],
					"text" : "Status"
				}
			},
			{
				"box" : 				{
					"id" : "obj-status",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 120.0, 344.0, 600.0, 22.0 ],
					"text" : "—"
				}
			},

			{
				"box" : 				{
					"id" : "obj-lbl-count",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 20.0, 380.0, 110.0, 20.0 ],
					"text" : "Countdown (sec)"
				}
			},
			{
				"box" : 				{
					"id" : "obj-countdown",
					"maxclass" : "number",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "bang" ],
					"patching_rect" : [ 130.0, 376.0, 120.0, 32.0 ],
					"fontsize" : 22.0
				}
			},

			{
				"box" : 				{
					"id" : "obj-cellblock",
					"maxclass" : "jit.cellblock",
					"numinlets" : 1,
					"numoutlets" : 4,
					"outlettype" : [ "", "", "", "" ],
					"patching_rect" : [ 20.0, 420.0, 600.0, 280.0 ],
					"rows" : 1,
					"columns" : 8
				}
			},

			{
				"box" : 				{
					"id" : "obj-hdr-server",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 700.0, 70.0, 460.0, 20.0 ],
					"text" : "── SERVER (right-click node.script → Debug to open Chrome DevTools) ──",
					"fontsize" : 12.0,
					"fontface" : 1
				}
			},

			{
				"box" : 				{
					"id" : "obj-loadbang",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"patching_rect" : [ 700.0, 96.0, 60.0, 22.0 ],
					"text" : "loadbang"
				}
			},

			{
				"box" : 				{
					"id" : "obj-defaults",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 4,
					"outlettype" : [ "bang", "bang", "bang", "bang" ],
					"patching_rect" : [ 700.0, 124.0, 130.0, 22.0 ],
					"text" : "t b b b b"
				}
			},

			{
				"box" : 				{
					"id" : "obj-def-port",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 700.0, 156.0, 50.0, 22.0 ],
					"text" : "8080"
				}
			},
			{
				"box" : 				{
					"id" : "obj-def-dur",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 760.0, 156.0, 50.0, 22.0 ],
					"text" : "20"
				}
			},
			{
				"box" : 				{
					"id" : "obj-def-solo",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 820.0, 156.0, 50.0, 22.0 ],
					"text" : "15"
				}
			},

			{
				"box" : 				{
					"id" : "obj-nodescript",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 700.0, 290.0, 320.0, 22.0 ],
					"text" : "node.script server.js @autostart 1 @watch 1 @restart 1"
				}
			},

			{
				"box" : 				{
					"id" : "obj-print-server",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1030.0, 320.0, 130.0, 22.0 ],
					"text" : "print SERVER"
				}
			},

			{
				"box" : 				{
					"id" : "obj-route-top",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 8,
					"outlettype" : [ "", "", "", "", "", "", "", "" ],
					"patching_rect" : [ 700.0, 326.0, 600.0, 22.0 ],
					"text" : "route performer roster countdown status url coverage complete cell"
				}
			},

			{
				"box" : 				{
					"id" : "obj-status-pre",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 880.0, 384.0, 100.0, 22.0 ],
					"text" : "prepend set"
				}
			},

			{
				"box" : 				{
					"id" : "obj-url-pre",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 980.0, 360.0, 100.0, 22.0 ],
					"text" : "prepend set"
				}
			},

			{
				"box" : 				{
					"id" : "obj-print-complete",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1180.0, 360.0, 130.0, 22.0 ],
					"text" : "print COMPLETE"
				}
			},

			{
				"box" : 				{
					"id" : "obj-coverage-print",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 1080.0, 360.0, 90.0, 22.0 ],
					"text" : "print COVERAGE"
				}
			},

			{
				"box" : 				{
					"id" : "obj-notes",
					"maxclass" : "comment",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 700.0, 420.0, 460.0, 280.0 ],
					"text" : "FIRST-TIME SETUP\n  1. open Terminal in this folder\n  2. run:  npm install\n     (installs ws — needed once)\n  3. Max:  the patch auto-starts the server.\n\nIF YOU CHANGE server.js\n  • @watch 1 reloads it automatically.\n  • or click START → STOP on the patch.\n\nDEBUG\n  • right-click [node.script] → Debug\n    opens Chrome DevTools attached to the\n    server (set breakpoints, eval, etc.).\n  • the SERVER print object (top right)\n    streams every routed message to the\n    Max console.\n\nPERFORMERS\n  • visit the Server URL from any device\n    on the same wifi.\n  • enter name → join.\n  • when conductor hits START, role buttons\n    activate.",
					"fontsize" : 11.0,
					"bgcolor" : [ 0.95, 0.95, 0.92, 1.0 ]
				}
			}
		],
		"lines" : [
			{ "patchline" : { "source" : [ "obj-num-port", 0 ], "destination" : [ "obj-msg-setport", 0 ] } },
			{ "patchline" : { "source" : [ "obj-msg-setport", 0 ], "destination" : [ "obj-nodescript", 0 ] } },

			{ "patchline" : { "source" : [ "obj-num-dur", 0 ], "destination" : [ "obj-msg-setdur", 0 ] } },
			{ "patchline" : { "source" : [ "obj-msg-setdur", 0 ], "destination" : [ "obj-nodescript", 0 ] } },

			{ "patchline" : { "source" : [ "obj-num-solo", 0 ], "destination" : [ "obj-msg-setsolo", 0 ] } },
			{ "patchline" : { "source" : [ "obj-msg-setsolo", 0 ], "destination" : [ "obj-nodescript", 0 ] } },

			{ "patchline" : { "source" : [ "obj-btn-start", 0 ], "destination" : [ "obj-msg-start", 0 ] } },
			{ "patchline" : { "source" : [ "obj-msg-start", 0 ], "destination" : [ "obj-nodescript", 0 ] } },

			{ "patchline" : { "source" : [ "obj-btn-stop", 0 ], "destination" : [ "obj-msg-stop", 0 ] } },
			{ "patchline" : { "source" : [ "obj-msg-stop", 0 ], "destination" : [ "obj-nodescript", 0 ] } },

			{ "patchline" : { "source" : [ "obj-btn-reset", 0 ], "destination" : [ "obj-msg-reset", 0 ] } },
			{ "patchline" : { "source" : [ "obj-msg-reset", 0 ], "destination" : [ "obj-nodescript", 0 ] } },

			{ "patchline" : { "source" : [ "obj-btn-clear", 0 ], "destination" : [ "obj-msg-clear", 0 ] } },
			{ "patchline" : { "source" : [ "obj-msg-clear", 0 ], "destination" : [ "obj-nodescript", 0 ] } },

			{ "patchline" : { "source" : [ "obj-loadbang", 0 ], "destination" : [ "obj-defaults", 0 ] } },
			{ "patchline" : { "source" : [ "obj-defaults", 0 ], "destination" : [ "obj-def-port", 0 ] } },
			{ "patchline" : { "source" : [ "obj-defaults", 1 ], "destination" : [ "obj-def-dur", 0 ] } },
			{ "patchline" : { "source" : [ "obj-defaults", 2 ], "destination" : [ "obj-def-solo", 0 ] } },
			{ "patchline" : { "source" : [ "obj-def-port", 0 ], "destination" : [ "obj-num-port", 0 ] } },
			{ "patchline" : { "source" : [ "obj-def-dur", 0 ], "destination" : [ "obj-num-dur", 0 ] } },
			{ "patchline" : { "source" : [ "obj-def-solo", 0 ], "destination" : [ "obj-num-solo", 0 ] } },

			{ "patchline" : { "source" : [ "obj-nodescript", 0 ], "destination" : [ "obj-print-server", 0 ] } },
			{ "patchline" : { "source" : [ "obj-nodescript", 0 ], "destination" : [ "obj-route-top", 0 ] } },

			{ "patchline" : { "source" : [ "obj-route-top", 2 ], "destination" : [ "obj-countdown", 0 ] } },

			{ "patchline" : { "source" : [ "obj-route-top", 3 ], "destination" : [ "obj-status-pre", 0 ] } },
			{ "patchline" : { "source" : [ "obj-status-pre", 0 ], "destination" : [ "obj-status", 0 ] } },

			{ "patchline" : { "source" : [ "obj-route-top", 4 ], "destination" : [ "obj-url-pre", 0 ] } },
			{ "patchline" : { "source" : [ "obj-url-pre", 0 ], "destination" : [ "obj-url", 0 ] } },

			{ "patchline" : { "source" : [ "obj-route-top", 5 ], "destination" : [ "obj-coverage-print", 0 ] } },
			{ "patchline" : { "source" : [ "obj-route-top", 6 ], "destination" : [ "obj-print-complete", 0 ] } },

			{ "patchline" : { "source" : [ "obj-route-top", 7 ], "destination" : [ "obj-cellblock", 0 ] } }
		]
	}
}
