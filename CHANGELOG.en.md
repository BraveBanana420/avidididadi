# What's new in Avidididadi

English translation of [CHANGELOG.md](CHANGELOG.md): same versions, same points, one line each. Greek: [CHANGELOG.el.md](CHANGELOG.el.md).

## 1.2.0

- Strength: the assistant prepares progressive plans (phases of a few weeks) with the app's exercises, starting from the sets you actually did.
- Assistant: a single reply can change several things at once (remove a session, add a workout or a plan) and is applied with "Apply all".
- Exercises per side: during the workout the right and left side are separate, with 5 seconds to switch side.
- New animated exercises: walking lunges, kneeling hip flexor, seated hamstring stretch, runner's stretch, child's pose and world's greatest stretch.
- Animated exercises: they now say the animations are made with AI.
- Voice on the bike: "go down to 95" and "go up to 85" instead of "below" and "above".
- Sessions with imported steps: moving or changing them no longer loses the steps.
- On opening, accept the privacy notice again (strength sets, equipment and strength plans also go to the assistant).

## 1.1.0

- Updates from the app: when a new version is out a notice appears and it installs with one tap, without Obtainium (Profile → App updates).
- Webhook (optional, off by default): the app can send your workout data to a web address you choose (Home Assistant, n8n, your own server…).
- Animated exercises: bodyweight squat and leg extension, the first of the new catalogue.
- Exercises in English: instructions rewritten to match the Italian ones, metric units only.
- Catalogue: the "Mobility and stretching" filter is now translated.
- What's new in each version also in English and Greek.
- App version at the bottom of the Profile, always in view.
- On opening, accept the privacy notice again (app updates).

## 1.0.2

- Images to share: the #avidididadi text now uses the logo font.

## 1.0.1

- Nothing changes in the app: it installs over 1.0.0 without losing any data.
- Automatic updates with Obtainium: badge and instructions on the GitHub page.
- Cleaner APK: removed a block of data for Google Play that isn't needed outside the Play Store.

## 1.0.0

- First public version: the code is on GitHub and the signed APK can be downloaded from the Releases page; it installs over 0.1.0 and 1.12.x without losing anything.
- Profile → Support the project: opens the Ko-fi donations page (optional, they don't unlock anything).
- Today: name, sport, duration and exercises of the session and the time of day in the chosen language (before they stayed in Italian).
- Push-ups: the two photos are back, as for the other exercises; the animations will be redone from scratch for the whole catalogue.
- Everything new since 1.12.3 is in the 0.1.0 section of CHANGELOG.en.md.

## 0.1.0

- Indoor cycling: the heart rate box only appears with the strap connected; without it, power takes the whole row.
- All icons rounded, with the same style on every page.
- Prepare the sessions: short titles that no longer wrap on narrow phones.
- Numbers that don't "jump" when they change, and come in with a small movement; in the guided workout the new exercise comes in smoothly.
- Weekly hours chart: a little space between the sports in each column and a "2 h, 4 h, 6 h" axis.
- Easier-to-read sport colours: same hue, darker on the light background (and cycling lighter on the dark one).
- Charts: axes on round numbers (0, 200, 400 W), pace on round times without stops squashing the scale.
- Themed map: roads, water and green areas stand out more from the background.
- Outdoor running, walking and cycling: on the "Data" page one value per row with big numbers while they fit; when steps, watts or cadence arrive the page switches by itself to a two-column grid, without scrolling.
- Today: the "+" steps aside while you scroll down and comes back as you scroll up; the ring and progress bar fill up when they appear.
- Week: with more workouts than planned it reads "5 done"; "1 exercise" instead of "1 exercises".
- Summary: zero-second segments no longer appear at the end of intervals.
- Structured run: in the "Planned and done" summary, a single chart with the intensity bands to hold and the line of the one held, in zones (heart rate or pace depending on the block's target).
- Cycling with watts: a single chart in the summary, with the coloured bars of the plan and the line of the real watts on top.
- Session summary: the pencil opens a single page for name, indoor/outdoor, data, strength exercises and deletion; at the bottom "Charts" and next to it the round button to share.
- Summary and images to share: next to the sport icon there is only the name of the session.
- First launch: once the sports are chosen, "Start today" creates the plan straight away (3 sessions of 30 minutes, Monday, Wednesday and Friday); the other questions are optional.
- Simple mode (Profile → Advanced features): zones, sensor icons, intervals.icu and file import stay hidden until needed; those who already used the app see everything.
- Profile: "My sensors" to connect a heart rate strap and bike sensors, also in simple mode.
- Today: invitation to turn on the automatic backup, a warning if the last one failed, and below the week the weeks in a row, milestones and records.
- Long run and long ride: can be turned off from "Prepare the sessions".
- Swimming: lengths corrected by hand count in the summary, charts and images to share.
- Rides recorded with the app: in the summary each block with the watts to hold and those held.
- Map during the workout: instead of the "i" there is the layers button, also in the minimap.
- Share: three designs for each sport (e.g. running: Map, Km by km, Poster; strength: Exercises, Muscles, Poster with the record; climbing: Session, Progress, Poster with the grade), plus "Your photo" from the gallery with the numbers on top; in Classic and Poster the route drawn sharply, on at every share and to turn off with the switch (when off, Classic shows a chart of the session); in the Map design the real Pulse, Streets or Satellite map, from a drop-down menu; "#avidididadi" brand at the top.
- Running and cycling sessions: the label says "Indoor" or "Outdoor".
- Version numbers reset: after 1.12.4 the app starts again from 0.1.0 and will move to 1.0.0 only at publication; it installs over the previous version without losing anything.
- "+" button: "Free workout" becomes "Strength"; at the end write down all the exercises done, with reps and kg (or bodyweight), also later from the session details; for planks and holds choose "Time" and write the seconds. Climbing moves to the bottom, before "Other activity".
- Other activity: you give it the name (e.g. Kayak), which stays on the session, and choose at the start whether to record the GPS route.
- Session summary: the segments done are split into the sections of the planned session (warm-up, main, cool-down), with the same titles and dots; one row per step, and the extra segments at the end of the session in a single row.
- Running and cycling from the watch (with intervals.icu): the segments are the real Garmin laps, also with the automatic 1 km lap; they only appear if the session has a structure (repeats, several steps), while long, easy and steady rides only show the totals.
- Sessions recorded with the app: every block is saved with the time done and planned, heart rate and watts, so you also see a block ended earlier than planned.
- Swimming from the watch (with intervals.icu): in the details you see the intervals with metres, time, pace and heart rate, and the rests; if the metres match the planned session they take the names of the steps. In the charts pace per 100 m and strokes per minute. The intervals can be corrected by hand: name, metres, time, order, segments to remove or add.
- Outdoor cycling without a power meter: steps in watts or in % of FTP are followed with the heart rate of the matching zone, with voice alerts; on screen you see watts and bpm.
- Long run: if you make it longer than planned it still counts as a long run, and the next long runs start from what you actually did.
- Workout without sensors: the exercise movement is shown large below the time; the heart rate box only appears when heart rate actually arrives.
- Coming back to the app, new sessions from the watch arrive by themselves, without closing and reopening it.
- Shorter messages at the bottom: they close by swiping in any direction and "Undo" has a border, so it isn't mistaken for closing.
- "+" menu and other bottom sheets: they no longer end up under the phone's buttons.
- Language: on first launch and from the Profile choose Italian, English or Greek; app, exercises, plan already created, coach and home screen widget follow the chosen language.
- Workout voice: it has its own language (During the workout → Voice language), which can differ from the app's.
- Running and walking: steps counted by the phone, with steps per minute, during the workout, in the notification and in the summary.
- Steps: the "Physical activity" permission is only asked the first time; turn them on and off from Profile → Data and connections → Steps from the phone.
- Back button: from Progress, Coach and Profile it goes back to Today; from Today it closes the app.
- App tour: "Next" and "Exit" always stay above the Android bar.
- On opening, accept the privacy notice again (location for "Other activity", steps from the phone).
- Threshold tests: new "Test" session type for running, cycling and swimming; in cycling a single "FTP test" (ramp on a smart trainer or 20 minutes on the road), in swimming 400 + 200 m giving the critical pace.
- On Today a test is only suggested when needed (FTP missing or unchanged for 8 weeks, intervals too easy), in place of a hard session; "later" postpones it by 2 weeks.
- FTP estimated from the rides of the last 6 weeks: if it goes up, the app asks whether to update it; FTP and critical pace already entered stay valid.
- My zones: "Take the test to calculate it" for cycling and swimming.
- Swimming recorded with the app: metres and pace per 100 m of each segment.
- Assistant: the message also includes the session blocks (with average and planned watts of the tests), watts, cadence, max HR, the watch segments with the names of the planned session and, for swimming, lengths, average pace and stroke.

## 1.12.3

- My activities: on first launch choose your sports and see only those; from the Profile add or remove them and the calendar updates.
- Climbing in the app: routes, boulders, grades and workouts written by hand or by the assistant, with their own charts.
- "+" button: all activities are always there, including "Other activity".
- Watch and intervals.icu: translated names (walking becomes Walking), the rest comes in as a free activity, without duplicates.
- Edit data: now works for all sessions, including those from the watch, and you can go back to the original data.
- Forgotten sessions: you can write down by hand an activity done on past days.
- Once a session is done you also see the workout that was planned.
- Voice: scrolling through the phases by hand interrupts it and it reads the one you see; grades are read properly (6a is "6 A").
- On opening, accept the privacy notice again (climbing data).

## 1.11.1

- Sessions recorded with the app: "Edit data" button in the details to correct duration, time, distance, heart rate, calories and notes.
- End of session: "Enter the data by hand" button in the summary.
- Swimming: lengths, pool length, metres, average time and stroke written by hand; they count in the statistics.
- Plans imported from the assistant: the app prepares the steps and the session can be started, also for those who do a single sport.
- Optional typical week: the plan starts from the sessions in the calendar, even if the days change every week.
- Those who install the app for the first time start from an empty week.
- intervals.icu: sessions sent by the app stay its own when they come back, with the right title and editable.
- On opening, accept the privacy notice again (data written by hand).

## 1.9.2

- Smart trainer: with the trainer connected, cycling switches by itself to the indoor screen, with speed and distance from the trainer.
- Trainer calibration from the app (sensors sheet), with a reminder every two weeks.
- Speed chart at the end of the session with the trainer or a sensor, from the next sessions.
- intervals.icu: with sending turned on in the Profile, recorded sessions go out by themselves, without a button.
- Running, cycling and walking start with the Start button, without a countdown; strength keeps it.
- Running, cycling and walking: time in a bar always in view instead of the circle.
- Minimap taking all the free space; watts and cadence only appear if the sensor sends them.
- Running FTP separate from the cycling one; steps per minute for running and walking.
- Cleaner free activities: double labels removed; names on one line on every screen.
- Walking easier to read on the light background.
- On opening, accept the privacy notice again (speed and automatic sending).

## 1.5.1

- Cycling: power zones from FTP (from intervals.icu or entered in Profile → My zones), sessions with the range of watts to hold.
- During the workout: power with the zone and range, voice alert if you go outside it; power chart and time in zones at the end of the session.
- Smart trainer (e.g. Tacx): the app sends it the watts of each step in ERG, with the −5% / +5% buttons.
- Cycling workout diagram with coloured bars, with the next block and how much is left.
- Coach in chat (Claude, GPT, Gemini, Ollama): prepares new plans and step-by-step workouts, to put in the calendar with one tap.
- Workouts from the assistant connected with the code: preview and "Put in the calendar"; with sending turned on they go straight to intervals.icu and Garmin.
- Share a session or the week as an image on WhatsApp or Instagram.
- Before the start you only see the timer and the choices (indoor, route).
- Strength: smaller timer and mini preview of the movement next to the exercise.
- Goal: sport icons instead of names.
- First launch: question about the watch, with what also works with the phone alone.
- Security fixes: safer backup restore, files that don't get corrupted, size limits.
- On opening, accept the privacy notice again (power and FTP).

## 1.3.0

- Routes to follow: load a GPX in "My routes" (Profile) or assign it to a session, and choose "Follow a route" in Get ready.
- Map during running, walking and cycling that turns in the direction of travel: two pages, minimap or full screen (Profile → During the workout).
- Voice directions: turns, off route, wrong way, arrival and km to go; on the bike alerts come earlier if you go fast.
- Route maps downloaded by themselves to use them without a connection too.
- Live data during the workout: distance, current and average pace or speed, last km overlaid with a beep and vibration.
- Live heart rate from a Bluetooth strap or a watch that broadcasts heart rate.
- Bike sensors via Bluetooth: smart trainers, power, speed and cadence.
- Voice during the workout (exercises, km, wrong zone and pace), silent during calls.
- Notification with time and data, also on the lock screen, with the Pause button.
- Optional auto-pause (off, only when stopped, below a speed) and average pace with or without stops.
- Indoor (treadmill, trainer): without GPS, at the end write the km shown on the display.
- If Android closes the app during a workout, when you reopen it you pick up where you were.
- App sessions can be sent to intervals.icu or saved as a GPX file.
- Automatic backup every day or week into a folder you choose.
- Estimated calories for sessions recorded with the app.
- A completed session can be deleted from the Edit button.
- On opening, accept the privacy notice again (Bluetooth sensors, notifications, routes and maps).

## 1.2.0

- New "+" button on Today: start a free activity straight away (running, walking, cycling, swimming, strength, mobility), which is added to the calendar.
- Walking is a new sport, with GPS and the route on the map.
- The initial countdown can also be skipped by tapping the timer.
- An activity done with the phone is no longer hidden by another one of the same sport recorded by the watch at a different time.
- On opening, accept the privacy notice again (GPS also for walking).

## 1.1.0

- Strength: log reps and kg of every set, with "last time" and records for each exercise.
- Beep and vibration in the last 5 seconds of rests and timed exercises.
- 42 exercises on gym machines and cables.
- "My plans": write down the plan from your personal trainer or coach (strength, running, cycling, swimming).
- intervals.icu: complete activities from Garmin and sending the plan to the watch.
- Map with roads and satellite; charts of heart rate, zones, pace, altitude and power.
- Today: swipe on the week to see the one before or after.
- App tour from the Profile.
- It installs over the old version without losing data; on opening, accept the privacy notice again.
