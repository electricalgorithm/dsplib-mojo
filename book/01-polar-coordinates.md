# Polar Coordinates and Why They Matter for Signal Processing

## 1. The Two Ways to Describe a Point

**Cartesian (x, y)**: "Go 3 units right, 4 units up"
**Polar (r, θ)**: "Point toward 53° with distance 5"

```
        y
        ^
        |     * (3,4)
        |    /|
        |   / |
        |  /  |  r = 5 (distance from origin)
        | / θ |  θ = 53° (angle from x-axis)
        |/____|________> x
       O
```

Same point, different descriptions. The conversion formulas:

```
r = √(x² + y²)
θ = atan2(y, x)

x = r · cos(θ)
y = r · sin(θ)
```

## 2. How Computers Store Complex Numbers

**Short answer: Store in Cartesian.** Almost every system—programming languages, CPUs, GPUs—uses (re, im) internally.

| Operation | Cartesian | Polar |
|-----------|-----------|-------|
| Addition | `re₁+re₂`, `im₁+im₂` (2 adds) | Needs law of cosines + trig (slow) |
| Multiplication | 4 mults + 2 adds | Just `r₁·r₂`, `θ₁+θ₂` (fast) |
| Magnitude | `sqrt(re²+im²)` (1 sqrt) | Direct access |
| Phase | `atan2(im,re)` (1 atan2) | Direct access |

### Why Polar Addition is Expensive

```
z₁ + z₂ in polar requires:
r = sqrt(r1² + r2² + 2*r1*r2*cos(θ2-θ1))
θ = atan2(r1*sin(θ1) + r2*sin(θ2), r1*cos(θ1) + r2*cos(θ2))
```
That's **2 trig + 2 sqrt + 4 mults** vs **2 adds** for Cartesian.

### The Key Insight

Signals live in **time domain** (addition territory). Operations like:
- Convolution = repeated addition
- Filtering = addition with past values

These would be catastrophic in polar form.

### Bottom Line

Store in Cartesian. Convert to polar **only when needed** for magnitude/phase extraction—then throw it away.

## 3. Euler's Formula and the Unit Circle

The magic formula that links everything:

```
e^(jθ) = cos(θ) + j·sin(θ)
```

This describes a point on the **unit circle** at angle θ:

```
           j (imaginary)
           |
           |         e^(jθ)
           |        /
           |       /
           |      /  r = 1 (always)
           |     /
           |    /
           |   / θ = angle in radians
           |  /
           | /
           |/__________> 1 (real)
          O
```

Every complex number can be written as:

```
z = r · e^(jθ) = r·cos(θ) + j·r·sin(θ)
```

### Why This Matters

When you multiply two complex numbers:
- **Cartesian**: Painful algebra (FOIL, combine terms)
- **Polar**: Just multiply magnitudes, add angles!

```
z₁ · z₂ = (r₁·e^(jθ₁)) · (r₂·e^(jθ₂)) = (r₁·r₂) · e^(j(θ₁+θ₂))
```

This is why **Fourier transforms** use complex exponentials—frequencies add when signals combine.

## 4. Phasors: Polar + Time

Here's the crucial insight: **Phasors = Polar + Time**.

| Aspect | Polar Coordinate | Phasor |
|--------|------------------|--------|
| Components | radius, angle | magnitude, phase |
| Angle means | direction | time offset |
| Static? | Yes | No—it's **rotating** |

### The Difference

```
Polar: "The point is 5 units away, at 53°"
Phasor: "The arrow is 5 units long, rotating at ω radians/sec,
         starting at 53°"
```

A phasor is a **rotating arrow** on the unit circle:

| Time | Phasor Position | Signal Value |
|------|-----------------|-------------|
| t=0 | θ = 0° | sin(0) = 0 |
| t=1 | θ = ω·t | sin(ω·t) |
| t=2 | θ = 2ω | sin(2ω) |
| ... | rotating | ... |

The **angular velocity** (how fast it rotates) = **frequency**. Higher frequency = faster spin.

### Why "Phase" Means Time, Not Just Direction

A sine wave: `sin(ωt + φ)`

- `ωt` = position on circle as time flows (rotation)
- `φ` = where it started (phase offset)

When we drop time and show a static phasor diagram, we're showing **the snapshot at t=0**. The rotation is implied.

### Phasor Diagram = Frozen Polar

```
At t=0:          At t=1ms:         At t=2ms:
    ↗                 ↗                ↗
   /                 /                /
  /                 /                /
 /                 /                /
O                 O                 O

The arrows rotate. The relative angles between them stay the same.
```

The relative phase (angle between arrows) tells you **time offset**, not just geometric direction.

## 5. The Unit Circle in DSP

The unit circle is the **visual language of sinusoidal signals**. It makes the invisible (frequencies, phase shifts) visible.

### Phase Differences Become Geometry

- 0° phase shift → arrow at 3 o'clock
- 90° phase shift → arrow at 12 o'clock
- 180° phase shift → arrow at 9 o'clock

A **phase difference** is just the **angle between two arrows**.

### Adding Signals = Adding Arrows

When you add two sinusoids with different phases:

```
sin(ωt) + sin(ωt + 45°)
```

You place both arrows head-to-tail. The **result** is another arrow (same frequency, different amplitude/phase).

### The DFT "Probes" Are Unit Circle Points

The DFT computes:
```
X[k] = Σ x[n] · e^(-j2πkn/N)
```

Each `e^(-j2πkn/N)` is a point on the unit circle. The DFT asks:
> "How much does my signal look like a spinning arrow at this speed?"

### Negative Frequency = Reverse Rotation

```
e^(+jωt)  = counterclockwise rotation (positive freq)
e^(-jωt)  = clockwise rotation (negative freq)
```

Real sine waves have **both** because `sin(ωt) = (e^(jωt) - e^(-jωt)) / 2j`. This is why DFT of real signals is symmetric.

## 6. Practical Visualization

```
         440 Hz wave
              │
              │     Phasor rotates 440 times/second
              │         ↗
              │        /  e^(j2π·440·t)
              │       /
              │      ●───> amplitude
              │  sin(2π·440·t)
              │
```

Without the unit circle, phase is an abstract number. With it, phase is a **direction**.

## Summary

| Concept | Unit Circle Meaning |
|---------|-------------------|
| Frequency | Rotation speed (RPM) |
| Phase | Arrow direction (compass heading) |
| Amplitude | Arrow length |
| Negative freq | Reverse rotation |
| Adding signals | Vector addition |

| View | Best For |
|------|----------|
| Cartesian | Addition/subtraction, real/imaginary parts |
| Polar | Multiplication/division, magnitude/phase, frequency analysis |
| Phasor | Time-varying sinusoids, phase relationships |

Polar coordinates exist because **rotation and scaling** (what signals do) are much easier to describe with angle and distance than with x and y. Phasors take this further by adding time—making the unit circle the perfect tool for understanding how sinusoids behave.
