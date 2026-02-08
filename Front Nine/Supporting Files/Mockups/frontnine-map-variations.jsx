import { useState } from "react";

const colors = {
  cream: "#FAF8F5",
  white: "#FFFFFF",
  text: "#2C2C2C",
  textLight: "#6B6360",
  sage: "#7D9A78",
  sageDark: "#6A8766",
  tan: "#D4C4B0",
  coral: "#E8A598",
  warmGray: "#A0938A",
};

const font = `-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro', 'Segoe UI', sans-serif`;

// Fake map tile using CSS
const MapVisual = ({ height, borderRadius, style }) => (
  <div style={{
    height, borderRadius, overflow: "hidden", position: "relative",
    background: "#e8ede4",
    ...style,
  }}>
    {/* Simplified map illustration */}
    <svg width="100%" height="100%" viewBox="0 0 400 300" preserveAspectRatio="xMidYMid slice">
      {/* Water */}
      <ellipse cx="80" cy="180" rx="70" ry="50" fill="#b8d4e3" opacity="0.6" />
      <ellipse cx="320" cy="100" rx="40" ry="60" fill="#b8d4e3" opacity="0.5" />
      {/* Fairways */}
      <path d="M150 0 Q200 80 180 160 Q160 220 200 300" stroke="#a8c49e" strokeWidth="35" fill="none" opacity="0.5" />
      <path d="M280 0 Q260 60 300 140 Q340 200 310 300" stroke="#a8c49e" strokeWidth="25" fill="none" opacity="0.4" />
      {/* Roads */}
      <path d="M0 80 Q100 70 200 90 Q300 110 400 100" stroke="#d4cfc8" strokeWidth="3" fill="none" opacity="0.6" />
      <path d="M0 220 Q150 200 250 230 Q350 250 400 240" stroke="#d4cfc8" strokeWidth="2.5" fill="none" opacity="0.5" />
      <line x1="180" y1="0" x2="190" y2="300" stroke="#d4cfc8" strokeWidth="2" opacity="0.4" />
      {/* Greens */}
      <circle cx="190" cy="90" r="8" fill="#7D9A78" opacity="0.6" />
      <circle cx="300" cy="200" r="6" fill="#7D9A78" opacity="0.5" />
      <circle cx="160" cy="240" r="7" fill="#7D9A78" opacity="0.6" />
    </svg>
    {/* Pin marker */}
    <div style={{
      position: "absolute", top: "50%", left: "50%",
      transform: "translate(-50%, -100%)",
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: "50% 50% 50% 0",
        background: colors.sage, transform: "rotate(-45deg)",
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: `0 2px 8px ${colors.sage}44`,
      }}>
        <div style={{
          width: 10, height: 10, borderRadius: "50%",
          background: colors.cream, transform: "rotate(45deg)",
        }} />
      </div>
    </div>
  </div>
);

// Tee box pills
const TeeBoxes = () => {
  const [selected, setSelected] = useState("White");
  const tees = ["Black", "Blue", "White", "Yellow", "Red"];
  return (
    <div>
      <div style={{
        fontSize: 13, fontWeight: 600, letterSpacing: 0.5,
        textTransform: "uppercase", color: colors.textLight, marginBottom: 8,
      }}>Tee Box</div>
      <div style={{ display: "flex", gap: 8 }}>
        {tees.map(t => (
          <button key={t} onClick={() => setSelected(t)} style={{
            padding: "7px 14px", borderRadius: 10,
            background: selected === t ? colors.sage : "transparent",
            color: selected === t ? colors.white : colors.text,
            border: `1.5px solid ${selected === t ? colors.sage : colors.tan}`,
            fontSize: 14, fontWeight: 550, fontFamily: font,
            cursor: "pointer", transition: "all 0.15s ease",
          }}>{t}</button>
        ))}
      </div>
    </div>
  );
};

// Stats row
const Stats = () => (
  <div style={{
    display: "grid", gridTemplateColumns: "1fr 1fr 1fr 1fr",
    background: colors.white, borderRadius: 14, padding: "14px 0",
    border: `1.5px solid ${colors.tan}33`,
  }}>
    {[
      { label: "Par", value: "72" },
      { label: "Rating", value: "69.9" },
      { label: "Slope", value: "127" },
      { label: "Yards", value: "6,007" },
    ].map((s, i) => (
      <div key={i} style={{
        textAlign: "center",
        borderRight: i < 3 ? `1px solid ${colors.tan}33` : "none",
      }}>
        <div style={{
          fontSize: 11, fontWeight: 600, letterSpacing: 0.5,
          textTransform: "uppercase", color: colors.textLight, marginBottom: 2,
        }}>{s.label}</div>
        <div style={{ fontSize: 22, fontWeight: 600, color: colors.text, letterSpacing: -0.5 }}>{s.value}</div>
      </div>
    ))}
  </div>
);

// ============================================
// VARIATION A: Compact card with rounded map
// ============================================
const VariationA = () => (
  <div style={{ background: colors.cream, minHeight: 757, padding: "20px 20px 40px" }}>
    {/* Back */}
    <button style={{
      background: "none", border: "none", cursor: "pointer",
      color: colors.sage, fontSize: 16, fontWeight: 500, fontFamily: font,
      display: "flex", alignItems: "center", gap: 4, padding: "0 0 16px",
    }}>
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={colors.sage} strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6" /></svg>
      Search
    </button>

    <h2 style={{ fontSize: 28, fontWeight: 600, color: colors.text, margin: 0, letterSpacing: -0.5, lineHeight: 1.15 }}>
      Miami Beach Golf Club
    </h2>
    <div style={{ fontSize: 15, color: colors.textLight, marginTop: 5, display: "flex", alignItems: "center", gap: 5, marginBottom: 20 }}>
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" /><circle cx="12" cy="10" r="3" />
      </svg>
      Miami Beach, FL
    </div>

    {/* Map as compact rounded card */}
    <div style={{
      borderRadius: 16, overflow: "hidden", marginBottom: 20,
      border: `1.5px solid ${colors.tan}33`,
      position: "relative", cursor: "pointer",
    }}>
      <MapVisual height={120} borderRadius={0} />
      {/* Tap to expand overlay */}
      <div style={{
        position: "absolute", bottom: 10, right: 10,
        background: "rgba(255,255,255,0.92)", backdropFilter: "blur(8px)",
        borderRadius: 8, padding: "5px 10px",
        fontSize: 12, fontWeight: 600, color: colors.textLight,
        display: "flex", alignItems: "center", gap: 4,
      }}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="15 3 21 3 21 9" /><polyline points="9 21 3 21 3 15" /><line x1="21" y1="3" x2="14" y2="10" /><line x1="3" y1="21" x2="10" y2="14" />
        </svg>
        Open in Maps
      </div>
    </div>

    <TeeBoxes />
    <div style={{ marginTop: 18 }}><Stats /></div>

    {/* Divider */}
    <div style={{ margin: "22px 0", height: 1, background: colors.tan, opacity: 0.3 }} />

    <button style={{
      width: "100%", padding: "16px 24px", background: colors.sage, color: colors.white,
      border: "none", borderRadius: 14, cursor: "pointer",
      fontSize: 17, fontWeight: 600, fontFamily: font,
    }}>Add & Rate This Course</button>
  </div>
);

// ============================================
// VARIATION B: Map as a subtle background peek
// ============================================
const VariationB = () => (
  <div style={{ background: colors.cream, minHeight: 757, position: "relative" }}>
    {/* Map peek at top */}
    <div style={{ position: "relative", height: 140, overflow: "hidden" }}>
      <MapVisual height={140} borderRadius={0} style={{ opacity: 0.7 }} />
      <div style={{
        position: "absolute", bottom: 0, left: 0, right: 0, height: 60,
        background: `linear-gradient(to top, ${colors.cream}, transparent)`,
      }} />
      {/* Back button over map */}
      <button style={{
        position: "absolute", top: 12, left: 12,
        background: "rgba(255,255,255,0.88)", backdropFilter: "blur(8px)",
        border: "none", borderRadius: 10, cursor: "pointer",
        color: colors.sage, fontSize: 14, fontWeight: 600, fontFamily: font,
        display: "flex", alignItems: "center", gap: 4, padding: "8px 12px",
      }}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={colors.sage} strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6" /></svg>
        Search
      </button>
      {/* Maps button */}
      <button style={{
        position: "absolute", top: 12, right: 12,
        background: "rgba(255,255,255,0.88)", backdropFilter: "blur(8px)",
        border: "none", borderRadius: 10, cursor: "pointer",
        color: colors.textLight, fontSize: 12, fontWeight: 600, fontFamily: font,
        display: "flex", alignItems: "center", gap: 4, padding: "8px 12px",
      }}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
          <polygon points="3 11 22 2 13 21 11 13 3 11" />
        </svg>
        Directions
      </button>
    </div>

    <div style={{ padding: "0 20px 40px" }}>
      <h2 style={{ fontSize: 28, fontWeight: 600, color: colors.text, margin: "0 0 5px", letterSpacing: -0.5, lineHeight: 1.15 }}>
        Miami Beach Golf Club
      </h2>
      <div style={{ fontSize: 15, color: colors.textLight, display: "flex", alignItems: "center", gap: 5, marginBottom: 22 }}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" /><circle cx="12" cy="10" r="3" />
        </svg>
        Miami Beach, FL
      </div>

      <TeeBoxes />
      <div style={{ marginTop: 18 }}><Stats /></div>
      <div style={{ margin: "22px 0", height: 1, background: colors.tan, opacity: 0.3 }} />
      <button style={{
        width: "100%", padding: "16px 24px", background: colors.sage, color: colors.white,
        border: "none", borderRadius: 14, cursor: "pointer",
        fontSize: 17, fontWeight: 600, fontFamily: font,
      }}>Add & Rate This Course</button>
    </div>
  </div>
);

// ============================================
// VARIATION C: Inline pill with address + map
// ============================================
const VariationC = () => (
  <div style={{ background: colors.cream, minHeight: 757, padding: "20px 20px 40px" }}>
    <button style={{
      background: "none", border: "none", cursor: "pointer",
      color: colors.sage, fontSize: 16, fontWeight: 500, fontFamily: font,
      display: "flex", alignItems: "center", gap: 4, padding: "0 0 16px",
    }}>
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={colors.sage} strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6" /></svg>
      Search
    </button>

    <h2 style={{ fontSize: 28, fontWeight: 600, color: colors.text, margin: 0, letterSpacing: -0.5, lineHeight: 1.15 }}>
      Miami Beach Golf Club
    </h2>
    <div style={{ fontSize: 15, color: colors.textLight, marginTop: 5, display: "flex", alignItems: "center", gap: 5, marginBottom: 22 }}>
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" /><circle cx="12" cy="10" r="3" />
      </svg>
      Miami Beach, FL
    </div>

    <TeeBoxes />
    <div style={{ marginTop: 18 }}><Stats /></div>

    {/* Location card — map + address inline */}
    <div style={{
      marginTop: 18, borderRadius: 14, overflow: "hidden",
      border: `1.5px solid ${colors.tan}33`,
      display: "flex", alignItems: "stretch",
      background: colors.white, cursor: "pointer",
    }}>
      {/* Mini map */}
      <div style={{ width: 90, flexShrink: 0, position: "relative" }}>
        <MapVisual height="100%" borderRadius={0} />
      </div>
      {/* Address info */}
      <div style={{ padding: "14px 14px", flex: 1, display: "flex", flexDirection: "column", justifyContent: "center" }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: colors.text, marginBottom: 2 }}>
          2301 Alton Rd
        </div>
        <div style={{ fontSize: 13, color: colors.textLight, lineHeight: 1.3 }}>
          Miami Beach, FL 33140
        </div>
        <div style={{
          fontSize: 12, fontWeight: 600, color: colors.sage,
          marginTop: 6, display: "flex", alignItems: "center", gap: 4,
        }}>
          <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
            <polygon points="3 11 22 2 13 21 11 13 3 11" />
          </svg>
          Get Directions
        </div>
      </div>
      <div style={{
        display: "flex", alignItems: "center", paddingRight: 12, color: colors.tan,
      }}>
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m9 18 6-6-6-6" /></svg>
      </div>
    </div>

    <div style={{ margin: "22px 0", height: 1, background: colors.tan, opacity: 0.3 }} />
    <button style={{
      width: "100%", padding: "16px 24px", background: colors.sage, color: colors.white,
      border: "none", borderRadius: 14, cursor: "pointer",
      fontSize: 17, fontWeight: 600, fontFamily: font,
    }}>Add & Rate This Course</button>
  </div>
);


// ============================================
// Main — variation switcher
// ============================================
export default function MapVariations() {
  const [variation, setVariation] = useState("A");

  return (
    <div style={{
      fontFamily: font, background: "#E8E4E0",
      minHeight: "100vh", display: "flex", flexDirection: "column",
      alignItems: "center", padding: "20px 16px",
    }}>
      {/* Variation picker */}
      <div style={{
        display: "flex", gap: 8, marginBottom: 20,
      }}>
        {[
          { key: "A", label: "Compact Card" },
          { key: "B", label: "Background Peek" },
          { key: "C", label: "Inline Address" },
        ].map(v => (
          <button key={v.key} onClick={() => setVariation(v.key)} style={{
            padding: "10px 18px", borderRadius: 12,
            background: variation === v.key ? colors.text : colors.white,
            color: variation === v.key ? colors.white : colors.text,
            border: `1.5px solid ${variation === v.key ? colors.text : colors.tan}`,
            fontSize: 14, fontWeight: 600, fontFamily: font,
            cursor: "pointer", transition: "all 0.15s ease",
          }}>
            {v.label}
          </button>
        ))}
      </div>

      {/* Phone frame */}
      <div style={{
        width: 375, height: 812, background: colors.cream,
        borderRadius: 40, border: "8px solid #1a1a1a",
        overflow: "hidden", position: "relative",
        boxShadow: "0 25px 50px rgba(0,0,0,0.15)",
      }}>
        {/* Dynamic Island */}
        <div style={{
          height: 47, background: colors.cream, position: "relative", zIndex: 10,
          display: "flex", justifyContent: "center", alignItems: "flex-end", paddingBottom: 8,
        }}>
          <div style={{ width: 120, height: 28, background: "#1a1a1a", borderRadius: 20 }} />
        </div>

        {/* Content */}
        <div style={{ overflowY: "auto", height: "calc(100% - 47px)" }}>
          {variation === "A" && <VariationA />}
          {variation === "B" && <VariationB />}
          {variation === "C" && <VariationC />}
        </div>

        {/* Home indicator */}
        <div style={{
          position: "absolute", bottom: 8, left: "50%", transform: "translateX(-50%)",
          width: 134, height: 5, background: "#1a1a1a20", borderRadius: 3, zIndex: 10,
        }} />
      </div>
    </div>
  );
}
