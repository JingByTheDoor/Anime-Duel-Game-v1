# Anime Duel v1 — Master Game Design Document
**Document type:** Master GDD / vertical-slice source of truth  
**Working title:** *Anime Duel*  
**Target build:** v1 first playable / vertical slice  
**Engine:** Godot  
**Platform:** PC  
**Input model:** Keyboard-first  
**Game mode:** Single-player vs AI only  
**Camera model:** 3D side-on duel with cinematic cut-ins  
**Roster:** Martial Artist, Samurai  
**Arena count:** 1  
**Document purpose:** Give an AI developer or human developer a single, rich, implementation-oriented understanding of the game, combining the original PRD and the two follow-up questionnaire answer sheets into one coherent design document.

---

## 1. How to use this document

This GDD is the **master design reference** for the vertical slice.

It merges:
- the original PRD,
- the first giant answers sheet,
- the second-pass massive answers sheet.

Where earlier notes conflict with later answers, **later locked answers win**.  
Practical precedence is:

1. **Locked systems and numeric tables in this GDD**
2. **Explicit “do not reopen unless playtest breaks it” rules**
3. **Implementation notes and formulas**
4. **Older exploratory prose**

This document is intentionally written for execution, not brainstorming.

---

## 2. High-level game summary

*Anime Duel* is a stylish anime-inspired duel game built around a hybrid of:
- **simultaneous hidden action selection**
- **short execution mini-games**
- **cinematic fight playback**

Every exchange begins with both fighters choosing an action under a short timer.  
Those hidden decisions create a baseline matchup. Then a short mini-game resolves execution quality. The result is converted into a flashy anime-style combat beat with VFX, camera work, hit stop, impact accents, and post-fight replay direction.

The game is meant to feel:
- strategic,
- skillful,
- readable,
- fair,
- anime-cool.

The vertical slice is deliberately narrow:
- 2 characters
- 1 arena
- 3 AI difficulties
- 1 duel mode
- no online
- no progression
- no unlock tree
- no meta systems
- no full training mode yet

The first playable exists to prove four things:
1. the duel loop is fun enough to replay,
2. the mini-games feel naturally fused with combat,
3. the fight presentation already feels anime-inspired,
4. outside testers can understand why the concept is cool.

---

## 3. Player fantasy and design pillars

### 3.1 Player fantasy
The player should feel like they are:
- reading the opponent,
- committing to a meaningful choice,
- proving execution under pressure,
- and then seeing that skill translated into a stylish anime clash.

The game should not feel like:
- random QTEs pasted onto combat,
- raw stat comparison,
- or dense tactics UI.

### 3.2 Core pillars
1. **Strategic clarity first**  
   The player must understand the top-level choice structure: Attack / Defend / Evade / Special, and if Attack then Fast / Power / Precision.

2. **Execution matters, but does not replace reads**  
   The system is intentionally closer to **60% read / 40% execution**. Correct strategic decisions matter more than raw mini-game mastery, but strong execution meaningfully changes outcomes.

3. **Anime spectacle with disciplined scope**  
   The game should feel dramatic even with limited content. Timing, camera, VFX, and replay direction matter more than huge animation libraries.

4. **Fairness and readability over complexity**  
   There is hidden depth, but the surface model remains learnable.

---

## 4. Scope snapshot

### In scope for v1
- single-player vs AI
- one-round duel
- simultaneous hidden action planning
- 7-second turn timer
- Attack / Defend / Evade / Special
- Attack subtypes: Fast / Power / Precision
- HP / Guard / Meter
- Guard Break and Vulnerable
- 3 mini-games
- 2 characters
- 1 cinematic arena
- 3 AI difficulties
- post-fight highlight replay
- minimal onboarding
- telemetry and debug support for balancing

### Explicitly out of scope for v1
- online multiplayer
- local PvP
- progression / unlock tree / account meta
- full training mode
- multiple arenas
- large roster
- rebinding UI
- advanced accessibility settings
- terrain hazards
- gameplay wall system
- full deterministic replay reconstruction
- deep story content

---

## 5. User stories

### Player user story
As a keyboard-first player who enjoys reaction, timing, and typing skill challenges, I want to play a stylish anime-inspired duel game where every attack, defense, and counter is resolved through short skill-based mini-games, so that winning feels both strategic and mechanically earned.

### Developer user story
As a solo developer prototyping the concept in Godot, I want a first playable that proves the core duel loop is fun, visually exciting, and understandable, without requiring large amounts of custom content, online infrastructure, or deep progression systems.

---

## 6. Intended player experience

The player should leave an early match feeling:
- “I understood what my choices meant.”
- “I lost because I guessed wrong, executed poorly, or both.”
- “Fast, Power, and Precision actually feel different.”
- “Guard pressure mattered.”
- “That replay made the fight look cooler than it mechanically was.”
- “I want another round.”

Target emotional texture:
1. tense
2. skillful
3. anime-cool / satisfying

---

## 7. Core game flow

1. **Title Screen**
2. **Character Select**
   - Martial Artist
   - Samurai
3. **Difficulty Select**
   - Easy
   - Normal
   - Hard
4. **Duel Intro**
5. **Repeated exchange loop**
   - planning
   - confirm
   - reveal
   - baseline resolve
   - mini-game or quick resolve
   - outcome
   - playback
   - recovery
   - end check
6. **Match end**
7. **Highlight replay**
8. **Result screen**
9. **Post-fight options**
   - rematch
   - switch character
   - switch difficulty
   - return to title

A duel is a **single round** with no between-round reset.

---

## 8. Match pacing targets

These are target feel values for v1:
- **Target duel length:** 2–3 minutes
- **Average exchanges per duel:** 8–12
- **Average exchange length including playback:** 8–12 seconds
- **Final blow:** always gets extra presentation weight
- **Match intensity:** rises visually as HP gets lower

Low-importance exchanges should stay short. Big reads, Guard Breaks, Specials, Perfects, and finishers should breathe longer.

---

## 9. Combat overview

The combat loop is:
1. both sides secretly choose an action,
2. the game resolves the matchup baseline,
3. one visible mini-game is presented to the player unless the exchange qualifies for quick resolve,
4. both sides receive grades (player visible, AI simulated),
5. outcome values are calculated,
6. the exchange is presented as a cinematic anime beat.

The combat is not fully deterministic from action picks alone, and not fully execution-driven either. It is a hybrid.

---

## 10. Combat resources

Each fighter has:

### 10.1 HP
Primary win/loss resource.  
When HP reaches zero, the fighter loses.  
Double KO is allowed and results in a **Draw** with dedicated result treatment.

### 10.2 Guard
Guard represents defensive stability and pressure tolerance. It is **not** just a second HP bar.

Guard:
- drops under pressure,
- drops on some direct hits,
- drops on failed defense,
- is heavily targeted by Power and Specials,
- can recover during breathing room or successful defense/evasion,
- can break.

### 10.3 Meter
Meter powers Specials.

### 10.4 Starting values
- **HP:** 100
- **Guard:** 100
- **Meter:** 0 / 100

Meter can store enough for **2 Specials** if the player reaches 100.

---

## 11. Core turn structure

### 11.1 Planning timer
Each exchange starts with a **7-second** shared planning phase.

### 11.2 Hidden lock-in
Both player and AI choose simultaneously from the player’s perspective.

### 11.3 Choice editing
The player may change their selection freely until:
- the timer expires, or
- they confirm early.

### 11.4 Early confirm
The player may confirm early.  
Early confirm does **not** give hidden gameplay advantage; it only improves pacing.  
If both sides are ready, the timer collapses into a brief dramatic pause.

### 11.5 Timeout behavior
If time runs out:
- if a choice is already highlighted, that choice is used,
- if nothing is selected, the game performs **Auto-Defend**.

Timeout can never resolve above **Weak** grade.

### 11.6 Reveal pause
After lock-in, the reveal pause lasts **0.45 seconds**.

### 11.7 Reset breath
After playback, the next planning phase begins after a **0.6 second** reset beat.

### 11.8 Simultaneous death
Both fighters can die in the same exchange.

---

## 12. Action set

The top-level actions are:
- **Attack**
- **Defend**
- **Evade**
- **Special**

When the player chooses **Attack**, they must choose one subtype:
- **Fast**
- **Power**
- **Precision**

There are no hard cooldowns in v1. Anti-spam comes from:
- matchup logic,
- Guard pressure,
- harsh punishment on Miss,
- special conditions,
- AI adaptation.

---

## 13. Action identities

### 13.1 Attack
Main pressure category.

### 13.2 Defend
Safest general stabilizer.  
Defend blunts attacks, recovers Guard, and can stabilize dangerous states, but should not dominate the meta.

### 13.3 Evade
Hard-read avoidance and punish tool.  
Evade is meant to be **rare but explosive**, not universally safe.

### 13.4 Special
Rule-breaker actions with visible conditions and meter cost.  
Strong, identity-defining, readable, and punishable on bad use.

---

## 14. Attack subtype identities

### 14.1 Fast
Role:
- speed
- control
- safety
- consistency
- tempo

Properties:
- lower HP damage
- lower commitment
- safer on failure
- lower Guard damage than Power
- good meter gain on success
- can sometimes catch shallow Evade
- least grade-sensitive of the three attack subtypes

Target fantasy: safe tempo snowball.

### 14.2 Power
Role:
- pressure
- Guard breaking
- heavy punish threat

Properties:
- highest Guard damage
- high HP damage
- slow / punishable
- best anti-Defend option
- worst baseline into Evade
- strong cinematic heaviness

Target fantasy: Guard pressure threat.

### 14.3 Precision
Role:
- execution-heavy punish
- hardest skill check
- highest payoff ceiling on clean success

Properties:
- hardest mini-game
- best reward on Perfect
- worst punishment on Miss
- weaker into solid Defend unless execution is high
- risky into Evade unless attacker performs well
- most grade-sensitive of the three attack subtypes

Target fantasy: high-skill payoff.

---

## 15. High-level interaction model

The game uses a **clear rock-paper-scissors backbone** with light hidden depth.

Visible structure:
- Attack is the main offensive tool.
- Defend is the safest stabilizer.
- Evade is the hard-read punish tool.
- Special breaks normal expectations but is still contestable.

Important principles:
- Defend can blunt attacks but usually does not erase all pressure.
- Power is the strongest anti-Defend attack.
- Evade should hard-punish the right committed read, especially into Power.
- Specials are not invincible win buttons.
- Same-subtype mirrors are generally resolved by grade; equal grades usually clash.

---

## 16. Baseline matchup logic

The combat matrix outputs one of these exchange states:
- `strike`
- `guarded_strike`
- `whiff_punish`
- `clash`
- `neutral_reset`
- `special_event`

For implementation, the matrix should also output:
- baseline winner
- baseline loser
- exchange state
- mini-game owner
- mini-game type
- grade sensitivity
- damage modifier
- Guard modifier
- meter modifier

### 16.1 Universal baseline matrix (v1)

| P1 | P2 | Baseline |
|---|---|---|
| Fast | Fast | clash |
| Fast | Power | strike (Fast favored) |
| Fast | Precision | strike (Fast favored) |
| Power | Fast | strike (Power disfavored) |
| Power | Power | clash |
| Power | Precision | strike (Precision favored) |
| Precision | Fast | strike (Precision disfavored) |
| Precision | Power | strike (Precision favored) |
| Precision | Precision | clash |
| Fast | Defend | guarded_strike |
| Power | Defend | guarded_strike (attacker favored) |
| Precision | Defend | guarded_strike (defender slightly favored) |
| Fast | Evade | strike / soft whiff-punish lean |
| Power | Evade | whiff_punish |
| Precision | Evade | soft whiff_punish |
| Defend | Defend | neutral_reset |
| Defend | Evade | neutral_reset |
| Evade | Evade | neutral_reset |
| Attack | Special | special_event |
| Defend | Special | special_event |
| Evade | Special | special_event |
| Special | Special | special_event |

### 16.2 Human-readable interpretation of key pairings

- **Fast vs Defend:** blocked; low HP, medium Guard pressure  
- **Power vs Defend:** attacker advantage; strong Guard pressure, possible chip feel  
- **Precision vs Defend:** defender advantage unless attacker grades high  
- **Fast vs Evade:** attacker slightly favored; Evade can still win cleanly with strong timing  
- **Power vs Evade:** Evade hard-favored; whiff punish window  
- **Precision vs Evade:** soft defender advantage  
- **Defend vs Defend:** neutral, both recover some Guard  
- **Defend vs Evade:** neutral, Evade side gets slightly better recovery / tempo  
- **Evade vs Evade:** hard neutral reset  
- **Special vs Special:** cinematic contest resolved by mini-game-driven special logic

### 16.3 True 50/50 baseline pairings
- Fast vs Fast
- Power vs Power
- Precision vs Precision
- some Special vs Special contests

### 16.4 Same-subtype resolution rule
If both sides choose the same attack subtype:
- better grade wins,
- equal grade usually becomes a clash / neutralized exchange,
- there is no hidden speed stat in v1.

---

## 17. Quick Resolve / low-impact exchange rules

Not every exchange spawns a foreground mini-game.

### 17.1 Definition
A **low-impact exchange** is one where:
- neither side chose an attack or active special,
- and the baseline result is a neutral reset or low-value stabilization,
- and there is no meaningful HP swing expected.

### 17.2 Skip timing
The decision to skip a mini-game is made:
- after reveal,
- after baseline matrix lookup,
- before mini-game spawn.

### 17.3 Allowed Quick Resolve pairings
- Defend vs Defend
- Evade vs Evade
- Defend vs Evade
- Evade vs Defend
- Defend vs locked-but-invalid Special fallback when it becomes Auto-Defend equivalent

### 17.4 Quick Resolve properties
Quick Resolve:
- shows **Quick Resolve**, not a grade,
- can grant meter,
- can grant Guard recovery,
- cannot produce KO,
- cannot produce Guard Break,
- does not create chip damage,
- does not create whiff recovery.

### 17.5 Quick Resolve meter gains
- Quick Resolve neutral: **+3**
- Quick Resolve evade-favored: **+4**

---

## 18. Grade system

The four universal outcome labels are:
- **Miss**
- **Weak**
- **Good**
- **Perfect**

The labels are shared globally, but thresholds are mini-game-specific.

### 18.1 Design intent
- Perfect should be rare and hype.
- Miss should happen mainly from panic, hard execution, or bad reads, not constantly.
- Grades affect not just numbers, but also presentation intensity and explanation tags.
- Precision is more grade-sensitive than Fast.
- Defend-based exchanges are less grade-sensitive than attack exchanges.

### 18.2 Grade interaction philosophy
- Baseline matchup happens first.
- Grade usually **modifies** the baseline rather than replacing it.
- A Miss on a favorable read can fully reverse the exchange.
- A Perfect on a bad read can sometimes steal a soft-counter situation, but should **not** reliably beat a hard counter.
- Correct strategic reads should guarantee some payoff unless the player Misses badly.

### 18.3 Outcome-step meaning
“Advantage” means the advantaged fighter gets:
- either **+1 outcome step on Good/Perfect**,  
- or slightly easier thresholds,  
depending on exchange type.

---

## 19. Mini-games

The game has exactly **3** core mini-game types in v1:
1. **Typing**
2. **Pattern Input**
3. **Reaction Timing**

Only **one foreground mini-game** is shown to the player in single-player.  
The opponent’s execution is simulated in the background.

In mirrored or contested exchanges, both fighters are conceptually graded, but the player sees a single decisive or shared mini-game.

### 19.1 Mapping philosophy
Mini-game mapping is **semi-fixed**:
- attack families strongly suggest one mini-game,
- Defend and Evade can vary slightly,
- some edge pairings may remap,
- attacks remain highly identifiable.

Pattern and Timing should appear more often than Typing.

### 19.2 Primary mapping
- **Fast** → Pattern Input
- **Power** → Reaction Timing
- **Precision** → Typing
- **Defend** → Reaction Timing
- **Evade** → short Pattern Input
- **Martial Artist Special** → Pattern Input
- **Samurai Special** → Reaction Timing

### 19.3 Mapping frequencies
- Fast uses Pattern **90%**
- Power uses Timing **95%**
- Precision uses Typing **95%**

### 19.4 Allowed variation
Variation is allowed mainly for:
- Defend
- Evade
- some Fast vs Evade edge cases
- some Precision vs Defend edge cases

### 19.5 Repetition rule
The same mini-game may appear twice in a row, but not more than **2 times in a row** unless a Special forces it.

---

## 20. Mini-game definitions

### 20.1 Typing
Format:
- English only
- lowercase only
- punctuation ignored
- short real words and short phrases

Launch constraints:
- keyboard layout: **QWERTY only**
- prompt pool size: **120 prompts**
- max prompt length: **14 characters**
- prompts should fit the duel theme
- avoid awkward uncommon-letter overload

Examples:
- `dash`
- `parry`
- `steel rain`
- `draw cut`
- `counter flow`

Typing scoring:
- weighted by **70% accuracy + 30% speed**
- one typo drops Perfect
- one typo does not automatically drop below Good if corrected quickly
- Backspace is allowed
- Backspace only hurts the grade if correction time pushes the result below threshold

### 20.2 Pattern Input
Pattern Input is the main Fast/Evade execution language.

Rules:
- sequence lengths: **3 / 4 / 5**
- launch input cluster should be tight and ergonomic
- recommended launch set: **A S D J K L**
- arrows are an acceptable fallback framing, but the recommended implementation is a tight keyboard cluster
- no mouse involvement in v1

Pattern meanings:
- short pattern: 3 keys
- medium pattern: 4 keys
- long pattern: 5 keys

### 20.3 Reaction Timing
Reaction Timing is a one-stop marker system with multiple difficulty variants.

Launch templates:
1. Standard center stop
2. Slightly faster sweep
3. Narrower Good zone
4. Heavy strike version with delayed start

No fake-outs in v1; timing windows are honest.

### 20.4 Data-driven implementation requirement
Each mini-game should be driven by data presets, not hardcoded constants, and should have a dedicated debug/test scene.

---

## 21. Grade thresholds by mini-game

### 21.1 Pattern Input thresholds
- **Miss:** wrong key, wrong order, or timeout
- **Weak:** one correction / late completion inside grace window
- **Good:** correct sequence in standard time
- **Perfect:** correct sequence in fast time with no errors

Default allowed times:
- 3 keys: **1.2s**
- 4 keys: **1.6s**
- 5 keys: **2.0s**

Timing bands:
- Weak: clean but >85% of allowed time, or one soft error with correction
- Good: clean within 50–85% of allowed time
- Perfect: clean within <50% of allowed time

### 21.2 Reaction Timing thresholds
Timing windows are symmetric around center.

Normalized value:
- **Miss:** outside ±0.24
- **Weak:** ±0.24 to ±0.11
- **Good:** ±0.11 to ±0.04
- **Perfect:** inside ±0.04

### 21.3 Typing thresholds
Score formula:
- 70% accuracy
- 30% speed

Result bands:
- **Miss:** <70% accuracy or timeout
- **Weak:** 70–89% accuracy or slow completion
- **Good:** 90–99% accuracy inside target time
- **Perfect:** 100% accuracy inside tight target time

---

## 22. Damage, Guard, and outcome math

### 22.1 Numeric style
Use **flat base values with light modifiers**, not deeply simulated percentages.

### 22.2 Base HP damage table

| Action | Miss | Weak | Good | Perfect |
|---|---:|---:|---:|---:|
| Fast | 0 | 6 | 10 | 14 |
| Power | 0 | 10 | 16 | 24 |
| Precision | 0 | 8 | 14 | 28 |

### 22.3 Base Guard damage table

| Action | Miss | Weak | Good | Perfect |
|---|---:|---:|---:|---:|
| Fast | 0 | 8 | 12 | 16 |
| Power | 0 | 14 | 22 | 30 |
| Precision | 0 | 6 | 12 | 18 |

### 22.4 Grade modifiers
Suggested tier modifiers:
- Miss: **0.0**
- Weak: **0.75**
- Good: **1.0**
- Perfect: **1.2**

### 22.5 Core formula
Final HP and Guard both follow this structure:

`Final = round((Base × matchup modifier × grade modifier × character modifier) + vulnerability bonus)`

Ordering:
- baseline matchup first,
- grade modification second,
- character identity modifier before final rounding,
- Vulnerable bonus after baseline, before final rounding,
- final values shown as integers.

### 22.6 Floors and ceilings
- **Global damage floor:** 1 for successful non-zero outcomes
- **Global damage ceiling:** 32 HP from a single exchange in v1

### 22.7 Additional combat math rules
- Power on Weak still applies minimum Guard pressure when not evaded.
- Fast may sometimes deal 0 HP and still create tempo / Guard pressure.
- Defend can convert pressure into minor advantage on Good/Perfect against weak Fast or Precision.
- Successful hard reads should still matter even if the numeric result is modest.

---

## 23. Meter system

### 23.1 Meter basics
- Meter max: **100**
- Special cost: **50**
- Meter is spent on successful Special activation at reveal, not on hover
- No refund on failed Special
- Meter can store up to 2 Specials

### 23.2 Meter gain table
- Land hit: **+8**
- Be hit: **+5**
- Successful Defend: **+6**
- Successful Evade: **+8**
- Perfect bonus: **+5**
- Guard Break caused: **+8**
- Quick Resolve neutral: **+3**
- Quick Resolve evade-favored: **+4**

### 23.3 Meter philosophy
Meter gain:
- happens on meaningful outcomes,
- does not happen on raw action commit,
- is mostly flat with light intensity bonuses,
- is roughly comparable for dealing and taking damage,
- should not create runaway comeback mechanics beyond Special access.

---

## 24. Guard system

### 24.1 Guard loss sources
Guard is reduced by:
- blocked pressure
- failed Defend
- direct hits (lightly)
- punish-flagged misses
- Specials

### 24.2 Guard recovery rules
Guard recovery happens after exchange resolution and before next selection.

Recovery values:
- Passive recovery after non-hit exchange: **+4**
- Successful Defend: **+12**
- Successful Evade: **+12**
- Defend vs Defend: **+10 both**
- Defend vs Evade: **Defend +8, Evade +10**
- Giant-sheet fallback guidance also implies non-attacking turns can trend toward recovery

Guard does **not** recover while Vulnerable.

### 24.3 Guard characteristics
- Fast can meaningfully chip Guard, but less than Power
- Power is the main Guard-break tool
- Precision can partially bypass Guard logic by converting strong grades into cleaner HP payoff rather than pure Guard pressure
- Guard is shown to the player as a **bar**, not constant numeric UI

---

## 25. Guard Break and Vulnerable

### 25.1 Guard Break
When Guard breaks:
- the defender remains interactive,
- the attacker gets next-exchange advantage,
- no free combo occurs,
- a guaranteed cinematic beat plays,
- pressure can continue after the break.

After the Vulnerable exchange resolves, Guard resets to **35**.

There is **no short-term immunity** in v1, so Guard can technically break again on the next exchange.

### 25.2 Vulnerable
Vulnerable is a **1-exchange debuff** caused mainly by Guard Break.

It:
- makes the target easier to pressure,
- makes the target worse at stabilizing,
- prevents Guard recovery,
- can stack with normal matchup advantage,
- cannot stack with another Vulnerable,
- can be consumed with no payoff if the advantaged side guesses wrong.

It expires if:
- both sides choose Defend, or
- the advantaged side whiffs.

### 25.3 Vulnerable effects
- Attacker gets **+10% HP modifier**
- Attacker gets **+15% Guard modifier**
- Defender mini-game thresholds worsen by **~10%**
- Attacker thresholds ease by **~5%**
- Defend and Evade under Vulnerable recover **4 less Guard**
- baseline result may improve by **one step** in some exchange types
- meter swing may tilt slightly toward the attacker
- presentation gets stronger

### 25.4 Defending while Vulnerable
The Vulnerable target still has access to all 4 actions, but:
- Defend is weaker,
- Evade is weaker,
- recovery is worse,
- stabilizing is harder.

---

## 26. Characters

The roster contains exactly **2 fighters** in v1.

### 26.1 Shared structure
Both fighters use:
- the same top-level rule system,
- the same action taxonomy,
- the same resources,
- the same overall combat architecture.

They differ by:
- tuning,
- attack feel,
- passive identity,
- special move,
- presentation style.

### 26.2 Martial Artist
Identity:
- faster rhythm
- better pressure flow
- stronger Fast identity
- easier for beginners
- better on Easy
- more agile recovery feel
- combo-like cadence

Passive: **Flow Pressure**

Effects:
- Fast Good/Perfect: **+2 bonus meter**
- Successful Evade: **+2 extra Guard recovery**
- Fast Weak uses **90% normal self-risk** instead of full self-risk

Special: **Momentum Rush**
- Condition: own HP ≤ 50
- Cost: 50 meter
- Mini-game: Pattern Input
- One exchange, presented as multi-hit
- One grade for the whole sequence
- Perfect branches to a stronger finisher presentation

Results:
- Miss: full whiff, self **-10 Guard**
- Weak: **12 HP / 12 Guard**
- Good: **18 HP / 18 Guard**
- Perfect: **26 HP / 22 Guard** and restore **10 own Guard**
- Against Vulnerable target: **+3 HP, +3 Guard**

### 26.3 Samurai
Identity:
- deliberate pacing
- stronger Power/Precision identity
- expert-leaning payoff
- higher skill ceiling
- bigger punish spikes
- heavier impact feel

Passive: **Lethal Read**

Effects:
- Power Perfect: **+2 Guard damage**
- Precision Perfect: **+4 HP damage**
- Power/Precision Miss self-risk: **+10%**

Special: **Decisive Cut**
- Condition: opponent Guard ≤ 35
- Cost: 50 meter
- Mini-game: Reaction Timing
- High-risk punish / finisher strike

Results:
- Miss: full whiff, self **-12 Guard**, exposed
- Weak: **14 HP / 10 Guard**
- Good: **22 HP / 16 Guard**
- Perfect: **32 HP / 20 Guard**
- Against Vulnerable target: **+4 HP**
- Perfect vs Vulnerable: force dramatic finisher camera

### 26.4 Character balance target
The two fighters should remain close in win rate.  
Samurai may be slightly harder and stronger in expert hands, but the gap should be small:
- acceptable win-rate difference in tests: **≤8%**

---

## 27. Special system rules

### 27.1 Core rules
- Specials are chosen in the same menu timing as all other actions
- no extra confirm beyond normal lock-in
- each Special always uses the same mini-game in v1
- Specials can be interrupted at baseline resolution if hard-countered
- Special vs Special is rare and cinematic

### 27.2 Activation checks
Special validity is checked:
1. at action-pick time
2. again at reveal

If the Special was valid during planning but invalid at reveal:
- it does **not** retroactively fire,
- it downgrades to an Auto-Defend-equivalent fallback,
- a penalty applies,
- the player should feel they lost the intended chance.

The design notes lock the existence of this penalty, but not a separate standalone numeric table for it. Implement it as a meaningful disadvantage state rather than a free neutral cancel.

### 27.3 Special presentation rules
- Specials should trigger at least **2 camera cuts**
- Specials should sit clearly above normal attacks in spectacle
- Special vs Special is resolved through special-event logic, usually mini-game-driven

---

## 28. AI design

### 28.1 AI philosophy
AI should feel like it is playing under the same combat rules as the player.  
It should not feel psychic or obviously cheating.

Difficulty affects:
- action choice quality
- simulated execution quality
- punish follow-through
- randomness
- ability to adapt to repetition

### 28.2 Difficulty personalities

#### Easy
- readable habits
- more randomness
- repeats mistakes
- weak Special timing
- teaches the player
- may overuse one action
- bluff frequency minimal

#### Normal
- reasonable reads
- basic punish logic
- mixed options
- uses Specials when obvious
- memory of 1 recent turn
- bluff frequency around 10%

#### Hard
- adapts to repetition
- stronger punish timing
- less randomness
- sharper Special use
- memory of last 2 turns
- anti-spam weights
- mid-match adaptation
- bluff frequency roughly 15–20%

### 28.3 AI decision inputs
AI utility scoring should consider:
- player HP
- player Guard
- own HP
- own Guard
- own meter
- opponent meter
- opponent Special availability
- whether enemy is Vulnerable
- last 2 player actions
- whether the player repeated a category
- whether a Special condition is live

### 28.4 AI behavioral heuristics
- prefers safer choices on low HP
- prefers Power when enemy Guard is low
- prefers Evade against repeated Power
- may choose suboptimal moves intentionally for human feel
- bluff behavior is state-based with a small random chance

### 28.5 Simulated execution odds

#### Easy
- Miss: 20%
- Weak: 45%
- Good: 30%
- Perfect: 5%

#### Normal
- Miss: 10%
- Weak: 25%
- Good: 50%
- Perfect: 15%

#### Hard
- Miss: 4%
- Weak: 16%
- Good: 50%
- Perfect: 30%

### 28.6 Type modifiers to AI grade odds
- Precision / Typing: **+4% Miss, -4% Perfect**
- Fast / Pattern: no change
- Power / Timing: **-2% Miss, +2% Good**

AI Special execution:
- slightly better than normal on Hard
- equal to normal on Normal
- slightly worse on Easy

Hard AI may still Miss rarely.

---

## 29. Controls and input language

### 29.1 Menu / action selection keys
- `1 / 2 / 3 / 4` = Attack / Defend / Evade / Special
- after choosing Attack:
  - `Q / W / E` = Fast / Power / Precision
- `Enter` = confirm early
- `Esc / Backspace` = go back

### 29.2 Input feel targets
- Attack submenu appears in **<100 ms**
- no animation delay before subtype selection
- advanced players may press `1` then `Q` almost instantly
- tiny input buffering is allowed between turns

### 29.3 Launch layout assumptions
- gameplay is keyboard-only
- supported layout: **QWERTY only**
- rebinding is not required in v1
- one-hand play is not a priority
- typing prompts should avoid awkward letter combinations

---

## 30. UI / UX

### 30.1 Layout
- main battle view occupies top-center majority of screen
- bottom command picker anchors player choice
- minimal HUD preserves spectacle

### 30.2 HUD contents
Always visible:
- player HP bar
- player Guard bar
- player Meter
- enemy HP bar
- enemy Guard bar
- enemy Meter
- planning timer
- mini-game grade splash when relevant

Avoid:
- constant dense stat text
- always-on move property numbers
- cluttered tactical sim readouts

### 30.3 Placement
- planning timer: **top-center**
- player resources: **top-left**
- enemy resources: **top-right**
- meter sits under the HP/Guard stack

### 30.4 Guard UI
- Guard is bar-only
- Guard color shifts at low values

### 30.5 Special UI
- locked Special appears visible but greyed out
- requirement text appears only on focus
- no direct AI prediction text is shown

### 30.6 Preview system
Preview is medium-information, hover/focus-driven, and based only on public logic.

Preview reflects:
- matchup truth
- self Guard
- enemy Guard
- self meter
- Special condition
- Vulnerable state

Max tags shown at once: **2**

Allowed preview vocabulary:
- Strong
- Risky
- Break Guard
- Good vs Power
- Good vs Low Guard
- Comeback
- Finisher
- Unsafe if Missed

Preview should never lie. It should only show “Strong” when the current state really supports it.

### 30.7 Explanation system
Important exchanges should show a short explanation line:
- location: center-bottom above picker
- max length: **6 words**
- should reference visible logic, not hidden system internals

Example templates:
- `Fast Good interrupted Power.`
- `Power Perfect cracked Guard.`
- `Evade punished a heavy read.`
- `Defend softened the strike.`
- `Precision Miss gave up the exchange.`
- `Decisive Cut punished low Guard.`

Vague explanations are worse than slightly repetitive explanations.

### 30.8 Grade feedback
Mini-game grades should appear as stylized splash text plus icon.  
Perfect receives a stronger typography treatment than Good.

---

## 31. Presentation and combat readability

### 31.1 Visual philosophy
The game should feel anime-inspired even with placeholder assets.  
This comes from:
- hit stop
- impact flash
- screen shake
- slash trails
- speed lines
- camera cuts
- slow motion on key beats
- freeze-frame on finishers

The game can rely heavily on VFX and camera rather than huge animation coverage.

### 31.2 Camera language
Baseline:
- mostly side-on
- close-ups on important beats
- occasional angled cut-ins for Specials and finishers

### 31.3 Camera budget
- neutral / low impact: 0–1 cuts
- standard exchange: 1 cut
- important exchange: 2 cuts
- Special / finisher: 2–3 cuts max

More than 2 major camera changes in a normal exchange is too much.

### 31.4 Camera triggers
Force close-ups on:
- Perfect
- Guard Break
- Special start
- Special hit
- finisher
- big whiff punish

Small exchanges should often stay side-view only.

### 31.5 Presentation flavor by action family
- **Fast:** short shots, snappy rhythm
- **Power:** heavier zoom, shake, stronger impact language
- **Precision:** cleaner pause, line emphasis, surgical payoff

### 31.6 Slow motion triggers
- Perfect
- Guard Break
- Special hit
- final blow

Non-finisher slow motion is allowed, but the game should avoid overusing it.

### 31.7 Miss presentation
Every Miss should have a short fail beat.  
It should communicate failure, but not become a comedy game.

### 31.8 Cheap-but-cool fallback path
When bespoke animation is missing, the game should still sell impact using:
- hit stop
- slash trails
- zoom
- screen FX
- audio emphasis

---

## 32. Replay / director system

### 32.1 Replay goal
After a match, the player should get a short, highly watchable highlight reel that:
- speeds past unimportant beats,
- preserves context,
- emphasizes strong moments,
- makes the fight feel even cooler.

### 32.2 Replay form
- automatic after the fight
- instantly skippable
- condensed highlights, not full reconstruction
- UI-free
- exaggerates timings
- uses data-driven camera tags, with room for later manual overrides

### 32.3 Replay length and structure
- target total length: **10–20 seconds**
- minimum highlight moments: **3**
- maximum highlight moments: **6**
- include one context/setup shot
- automatically shorten if the match was dull

### 32.4 Forced-in replay moments
Always include:
- final blow
- Guard Break

Double KO should also be treated as highly important.

### 32.5 Replay importance scoring
Suggested importance points:
- Perfect: +3
- Guard Break: +4
- Special: +4
- 20+ HP hit: +3
- Vulnerable punish: +2
- finisher: +5
- double KO: +5

Replay selection should consider:
- importance score,
- event diversity,
- avoiding 3 very similar moments in a row.

### 32.6 Logged data needed per exchange
Replay logging should capture at minimum:
- turn number / turn index
- both chosen actions
- subtypes
- Special condition state
- visible grade / simulated grade
- baseline state
- HP delta
- Guard delta
- meter delta
- guard break flag
- vulnerability application
- Special fired flag
- KO / finisher / draw flags
- replay importance score
- camera suggestion tags
- explanation key

---

## 33. Arena

### 33.1 Arena theme
The single arena for v1 is a **stylized dusk shrine rooftop courtyard**.

### 33.2 Arena philosophy
The arena is presentation-only in v1.  
It may support:
- sparks
- dust bursts
- debris
- slash trails
- impact decals
- visual wall-hit treatment
- light prop reactions

It may not support:
- gameplay hazards
- terrain advantage
- collision gimmicks
- meaningful wall mechanics

### 33.3 Lighting
- one lighting setup only for v1

### 33.4 Required interactions
- dust puffs
- sparks
- slash trails
- impact debris
- speed-line overlays
- light prop hit reactions

### 33.5 Optional polish
- petals / leaves
- cloth / banner motion
- lantern swings
- atmospheric embers
- extra debris layering

Wall hits may appear visually even without a gameplay wall system.

Destruction is mostly temporary in v1, with optional light persistent decals.

---

## 34. Onboarding and tutorial

### 34.1 Onboarding philosophy
The game needs minimal onboarding before outside testing.  
It does **not** need a giant tutorial.

### 34.2 Tutorial format
Use a hybrid onboarding approach:
- one very short guided sandbox duel
- then contextual early tips

### 34.3 Tutorial specifics
- default tutorial character: **Martial Artist**
- first guided action: **Attack → Fast**
- tutorial is a safe scripted sandbox
- tutorial should deliberately show:
  - one mini-game
  - one Guard Break
  - one Special
  - preview tags
  - HP vs Guard difference
  - grade labels
  - Vulnerable

### 34.4 Tutorial duration
- maximum acceptable tutorial length: **90 seconds**
- player can skip tutorial after first completion

### 34.5 What must be understood in the first 2 minutes
- planning timer
- Attack / Defend / Evade / Special
- Fast / Power / Precision
- grade labels
- Guard Break and Vulnerable
- Special condition and meter

Skipped exchanges do not need explicit tutorial explanation in v1.

---

## 35. Technical architecture

### 35.1 Core architecture
The game should use:
- one combat scene
- reusable mini-game overlays / sub-scenes
- a state machine + data table hybrid
- Godot Resources or equivalent editable data containers
- simplified replay logs rather than full deterministic reconstruction

### 35.2 Combat state machine
Recommended states:
1. Init
2. Intro
3. Planning
4. Confirm
5. Reveal
6. ResolveBaseline
7. SpawnMiniGame
8. MiniGameActive
9. ResolveOutcome
10. Playback
11. Recovery
12. CheckEnd
13. Replay
14. Result

### 35.3 Central controller
Use one master `CombatController` to coordinate flow.

### 35.4 Data representation
Actions should be represented as:
- enums for logic flow
- data resources for editable behavior

### 35.5 Required data containers
Use separate resources / data files for:
- `BalanceData`
- `CharacterData`
- `MiniGameData`

### 35.6 ExchangeResult packet
Each exchange should resolve into a single `ExchangeResult` data packet containing:

- `turn_index`
- `p1_action`
- `p1_subtype`
- `p2_action`
- `p2_subtype`
- `baseline_state`
- `mini_game_type`
- `mini_game_owner`
- `p1_grade`
- `p2_grade_abstract`
- `hp_delta_p1`
- `hp_delta_p2`
- `guard_delta_p1`
- `guard_delta_p2`
- `meter_delta_p1`
- `meter_delta_p2`
- `vulnerability_applied`
- `guard_break`
- `special_fired`
- `camera_tags`
- `explanation_key`

### 35.7 Debug support
The prototype should include:
- deterministic seed logging
- in-game debug overlay
- debug commands to force:
  - Guard Break
  - Special availability
  - specific mini-game
  - specific grade

### 35.8 Performance target
- **60 FPS**

### 35.9 Hit stop implementation note
Hit stop should pause:
- character motion
- gameplay timers
- key animation movement

Audio should duck / accent rather than fully hard-stop.

---

## 36. Production scope and asset strategy

### 36.1 Minimum character animation set
Each character needs at minimum:
- idle / stance
- intro pose
- hit react
- defend pose
- evade pose
- 1 Fast strike base
- 1 Power strike base
- 1 Precision strike base
- 1 Special base
- finisher hit

### 36.2 Safe reuse
These can be reused with timing / camera variation:
- Fast family
- Power family
- some Defend / Evade recoveries
- some contact reactions

### 36.3 Mandatory VFX
- hit spark
- slash trail
- impact flash
- screen shake
- speed lines
- Guard crack effect

### 36.4 Mandatory sounds
- UI confirm
- timer warning
- light hit impact
- heavy hit impact
- Guard hit
- Guard break
- Special charge / cut

### 36.5 Visual direction
Preferred art direction:
- stylized low-poly
- cel-shaded lean
- not pixel-filtered

### 36.6 Tooling note
Smack Studio can be used as a reference or prototyping aid, but should not become a hard dependency for the final pipeline.

### 36.7 Most dangerous missing asset
The asset gap that hurts the concept most is **weak hit feel**.

---

## 37. Acceptance criteria

The vertical slice is accepted when all of the following are true:

1. The player can start the game, select a character, select difficulty, and finish a full duel against AI.
2. The duel uses simultaneous hidden action selection with a working turn timer.
3. The player can choose Attack / Defend / Evade / Special.
4. Attack branches into Fast / Power / Precision.
5. All 3 mini-game types are playable and integrated into duel resolution.
6. Mini-games produce Miss / Weak / Good / Perfect outcomes.
7. Outcomes visibly affect combat state, not just hidden numbers.
8. HP, Guard, and Meter all function correctly.
9. Guard Break creates Vulnerable without removing defender agency.
10. Martial Artist and Samurai feel distinct in play and presentation.
11. AI supports both characters and 3 difficulties.
12. The fight is readable without dense stat UI.
13. The battle feels anime-inspired even with limited content.
14. A post-fight replay plays successfully and emphasizes dramatic moments.
15. The build is stable enough to hand to testers.

---

## 38. Success metrics

### 38.1 Primary success metrics
- Players say the duel is fun enough to replay.
- Players say the mini-games feel integrated rather than pasted on.
- Players say the fight already feels like an anime clash.

### 38.2 Secondary success metrics
- Testers understand the action-selection structure without long explanation.
- Players can identify Martial Artist vs Samurai playstyle differences.
- Players feel Miss, Good, and Perfect meaningfully affect tension and payoff.
- Testers want to replay to improve both strategy and execution.

### 38.3 Personal success criteria
The prototype is successful if:
- the duel is genuinely fun,
- the game looks and feels like an anime fight,
- the mini-games feel naturally fused with combat,
- outside testers quickly understand why the concept is cool.

---

## 39. Balance philosophy

The healthiest version of the game is one where **adaptation** is strongest on average.

### 39.1 Role targets
- **Fast:** safe tempo
- **Power:** Guard pressure threat
- **Precision:** high-skill payoff
- **Evade:** rare explosive hard read
- **Defend:** stable but not dominant

### 39.2 Desired usage ranges
- Attack total: **45–60%**
- Defend: **20–30%**
- Evade: **10–20%**
- Special: **5–10%**

### 39.3 Health targets
- beginners should overuse Attack, not Defend
- Power should scare through Guard pressure first, raw damage second
- Precision should scare through payoff, not by invalidating every bad matchup
- Fast should win through safety and tempo
- Evade should be rare but exciting
- most duels should include at least one Guard Break about **60%** of the time
- most duels should include at least one Special attempt about **45%** of the time
- most duels should end from momentum spikes after Guard pressure, not flat HP chipping

### 39.4 Red flags
- any single action category above **45%** sustained use in balanced tests
- any action or subtype over **40%** pick rate in non-beginner tests
- one option feeling “always best”
- fights feeling visually flat
- mini-games feeling disconnected
- players not understanding why they lost exchanges

---

## 40. Telemetry and playtesting

### 40.1 Core telemetry to log
- action pick rates
- subtype pick rates
- win rates by character
- win rates by difficulty
- mini-game grade distributions
- mini-game fail rates
- Guard Break count per duel
- average duel length
- replay skip rate
- skipped exchange count
- explanation-line display count
- early-confirm frequency

### 40.2 Key numerical watchpoints
- acceptable character win-rate gap: **≤8%**
- any category above **45%** sustained use is a strong red flag
- any action/subtype above **40%** in non-beginner testing suggests spam dominance

### 40.3 Post-playtest questions
1. Did you understand what Attack / Defend / Evade / Special were doing?
2. Did Fast / Power / Precision feel meaningfully different?
3. Did the mini-games feel connected to combat or pasted on top?
4. Did you ever feel like one option was always best?
5. Did the fight feel anime-cool?
6. Did you understand why you won or lost each exchange?
7. Was the replay exciting or too long?
8. Which mini-game felt best and which felt worst?

---

## 41. Build order recommendation

Recommended build order:

1. Combat state machine
2. Action picker + timer
3. AI decision + simulated grade model
4. Three mini-game overlays
5. HP / Guard / Meter resolution
6. Baseline playback / camera / hit stop
7. Character tuning split
8. Special system
9. Replay highlight reel
10. Tutorial / onboarding pass

---

## 42. Change policy for prototyping

### 42.1 Numbers that are allowed to change freely during testing
- damage values
- threshold values
- meter values
- recovery values
- replay pacing
- camera emphasis

### 42.2 Rules that must not drift casually
- action interaction backbone
- Fast / Power / Precision identity
- Guard Break / Vulnerable meaning
- Special conditions
- turn flow

### 42.3 Priority order when values conflict
If “feel” and “clarity” conflict, the priority order is:
1. readability
2. fairness
3. anime spectacle

### 42.4 Most acceptable simplification
If time runs short, simplify **replay depth** first.

### 42.5 Least acceptable compromise
Do **not** muddy combat readability.

---

## 43. Final locked rules

Do not reopen these unless a playtest clearly breaks them:

- 7-second planning timer
- simultaneous hidden lock-in
- one-round duel
- 100 HP / 100 Guard / 0 Meter start
- 2 characters
- 1 arena
- 3 mini-games
- Attack / Defend / Evade / Special
- Fast / Power / Precision
- Guard Break creates Vulnerable for 1 exchange
- Specials cost 50
- keyboard-first
- replay may simplify
- combat clarity may not simplify

---

## 44. Appendix — one-page implementation summary

If an AI developer only remembers one page, it should remember this:

- Build a **single-player, keyboard-first anime duel** in Godot.
- Two fighters secretly choose **Attack / Defend / Evade / Special** every 7 seconds.
- If Attack is chosen, player picks **Fast / Power / Precision**.
- Resolve with a **baseline combat matrix** first, then a **single visible mini-game** for the player unless the exchange is one of the neutral quick-resolve cases.
- Mini-games are:
  - Fast → Pattern
  - Power → Timing
  - Precision → Typing
- Grades are **Miss / Weak / Good / Perfect**.
- Combat is **60% read / 40% execution**.
- HP / Guard / Meter all matter.
- Guard Break does **not** stun-lock the defender; it creates **Vulnerable** for 1 exchange.
- Martial Artist = safer flow / Fast pressure.
- Samurai = riskier, deadlier read payoff.
- Every exchange must become an **anime-style playback beat**.
- After the match, play a **short highlight replay** with 3–6 moments.
- If time gets tight, reduce replay complexity, never combat clarity.
