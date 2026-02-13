
const courses = [
  {
    rank: 1, name: "Pebble Beach Golf Links", location: "Pebble Beach, CA", tier: "loved",
    type: "Links", par: 72, yards: "6,828", datePlayed: "Sep 2024",
    img: "https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=200&h=200&fit=crop&crop=center",
    badge: null
  },
  {
    rank: 2, name: "Augusta National Golf Club", location: "Augusta, GA", tier: "loved",
    type: "Parkland", par: 72, yards: "7,545", datePlayed: "Apr 2024",
    img: "https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=200&h=200&fit=crop&crop=center",
    badge: "PRIVATE"
  },
  {
    rank: 3, name: "Miami Beach Golf Club", location: "Miami Beach, FL", tier: "loved",
    type: "Parkland", par: 72, yards: "6,615", datePlayed: "Aug 2024",
    img: "https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=200&h=200&fit=crop&crop=center",
    badge: null
  },
  {
    rank: 4, name: "Normandy Shores Golf Club", location: "Miami Beach, FL", tier: "loved",
    type: "Links", par: 71, yards: "6,805", datePlayed: "Aug 2024",
    img: "https://images.unsplash.com/photo-1600006195068-3544661040db?w=200&h=200&fit=crop&crop=center",
    badge: null
  },
  {
    rank: 5, name: "St Andrews Old Course", location: "St Andrews, Scotland", tier: "loved",
    type: "Links", par: 72, yards: "7,305", datePlayed: "Jun 2024",
    img: "https://images.unsplash.com/photo-1621508638997-e30808c10653?w=200&h=200&fit=crop&crop=center",
    badge: null
  },
  {
    rank: 6, name: "Torrey Pines South", location: "La Jolla, CA", tier: "liked",
    type: "Links", par: 72, yards: "7,698", datePlayed: "Jul 2024",
    img: "https://images.unsplash.com/photo-1560150054-1a50bc tried390?w=200&h=200&fit=crop&crop=center",
    badge: null
  },
  {
    rank: 7, name: "Bethpage Black", location: "Farmingdale, NY", tier: "liked",
    type: "Parkland", par: 71, yards: "7,468", datePlayed: "May 2024",
    img: "https://images.unsplash.com/photo-1632167764165-74a3d686e9f8?w=200&h=200&fit=crop&crop=center",
    badge: null
  },
  {
    rank: 8, name: "Bandon Dunes", location: "Bandon, OR", tier: "liked",
    type: "Links", par: 72, yards: "6,732", datePlayed: "Mar 2024",
    img: "https://images.unsplash.com/photo-1611374243147-44a702c2d44c?w=200&h=200&fit=crop&crop=center",
    badge: null
  },
  {
    rank: 9, name: "Muni Executive 9", location: "Springfield, IL", tier: "didnt_love",
    type: "Executive", par: 27, yards: "1,890", datePlayed: "Feb 2024",
    img: "https://images.unsplash.com/photo-1580128660010-fd027e1e587a?w=200&h=200&fit=crop&crop=center",
    badge: "9 HOLES"
  }
];

const tierConfig = {
  loved: {
    label: "LOVED",
    icon: "🚩",
    accentColor: "#B8604A",
    numberColor: "#C4705A",
    barColor: "#B8604A",
    bgGradient: "linear-gradient(180deg, rgba(184,96,74,0.06) 0%, rgba(184,96,74,0.02) 100%)",
    sectionBorder: "rgba(184,96,74,0.15)"
  },
  liked: {
    label: "LIKED",
    icon: "🏌️",
    accentColor: "#7A8B6F",
    numberColor: "#8A9B7F",
    barColor: "#7A8B6F",
    bgGradient: "linear-gradient(180deg, rgba(122,139,111,0.06) 0%, rgba(122,139,111,0.02) 100%)",
    sectionBorder: "rgba(122,139,111,0.15)"
  },
  didnt_love: {
    label: "DIDN'T LOVE",
    icon: "⛳",
    accentColor: "#A0968A",
    numberColor: "#B0A69A",
    barColor: "#A0968A",
    bgGradient: "linear-gradient(180deg, rgba(160,150,138,0.06) 0%, rgba(160,150,138,0.02) 100%)",
    sectionBorder: "rgba(160,150,138,0.15)"
  }
};

function CourseRow({ course, isFirst }) {
  const tier = tierConfig[course.tier];

  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        padding: isFirst ? "18px 16px 18px 12px" : "14px 16px 14px 12px",
        position: "relative",
        gap: "12px",
        borderBottom: "1px solid rgba(0,0,0,0.05)",
        transition: "background 0.2s ease",
        cursor: "pointer",
        ...(isFirst ? {
          background: "linear-gradient(135deg, rgba(184,96,74,0.05) 0%, rgba(212,175,55,0.04) 100%)",
          borderRadius: "12px",
          margin: "0 8px 4px 8px",
          border: "1px solid rgba(184,96,74,0.1)",
          borderBottom: "1px solid rgba(184,96,74,0.1)",
        } : {})
      }}
      onMouseEnter={e => e.currentTarget.style.background = isFirst ? "linear-gradient(135deg, rgba(184,96,74,0.08) 0%, rgba(212,175,55,0.06) 100%)" : "rgba(0,0,0,0.02)"}
      onMouseLeave={e => e.currentTarget.style.background = isFirst ? "linear-gradient(135deg, rgba(184,96,74,0.05) 0%, rgba(212,175,55,0.04) 100%)" : "transparent"}
    >
      {/* Rank Number */}
      <div style={{
        width: "32px",
        flexShrink: 0,
        textAlign: "center",
        position: "relative"
      }}>
        {isFirst && (
          <div style={{
            position: "absolute",
            top: "-10px",
            left: "50%",
            transform: "translateX(-50%)",
            width: "14px",
            height: "6px",
            display: "flex",
            alignItems: "flex-end",
            justifyContent: "center",
            gap: "2px",
          }}>
            <div style={{ width: "2px", height: "6px", background: "#C9A96E", borderRadius: "1px" }} />
            <div style={{ width: "2px", height: "4px", background: "#C9A96E", borderRadius: "1px" }} />
            <div style={{ width: "2px", height: "6px", background: "#C9A96E", borderRadius: "1px" }} />
          </div>
        )}
        <span style={{
          fontFamily: "'Playfair Display', Georgia, serif",
          fontSize: isFirst ? "32px" : "26px",
          fontWeight: 300,
          color: tier.numberColor,
          lineHeight: 1,
          letterSpacing: "-0.02em"
        }}>
          {course.rank}
        </span>
      </div>

      {/* Accent Bar */}
      <div style={{
        width: "3px",
        height: isFirst ? "52px" : "44px",
        borderRadius: "2px",
        background: `linear-gradient(180deg, ${tier.barColor} 0%, ${tier.barColor}66 100%)`,
        flexShrink: 0,
      }} />

      {/* Course Info */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <span style={{
          fontFamily: "'DM Sans', 'Avenir', sans-serif",
          fontSize: isFirst ? "16px" : "15px",
          fontWeight: 600,
          color: "#2C2C2C",
          letterSpacing: "-0.01em",
          lineHeight: 1.3,
        }}>
          {course.name}
        </span>

        <div style={{
          display: "flex",
          alignItems: "center",
          gap: "8px",
          marginTop: "3px",
        }}>
          <span style={{
            fontFamily: "'DM Sans', 'Avenir', sans-serif",
            fontSize: "13px",
            color: "#8B8178",
            letterSpacing: "0.01em",
          }}>
            {course.location}
          </span>
          {course.badge && (
            <span style={{
              fontSize: "9px",
              fontWeight: 700,
              letterSpacing: "0.08em",
              color: course.badge === "PRIVATE" ? tier.accentColor : "#8B8178",
              border: `1px solid ${course.badge === "PRIVATE" ? tier.accentColor + "40" : "#8B817840"}`,
              borderRadius: "4px",
              padding: "2px 6px",
              background: course.badge === "PRIVATE" ? tier.accentColor + "0A" : "#8B81780A",
              whiteSpace: "nowrap",
            }}>
              {course.badge}
            </span>
          )}
        </div>

      </div>

      {/* Chevron */}
      <div style={{
        flexShrink: 0,
        color: "#C8C0B8",
        fontSize: "18px",
        fontWeight: 300,
      }}>
        ›
      </div>
    </div>
  );
}

function TierSection({ tier, tierCourses }) {
  const config = tierConfig[tier];

  return (
    <div style={{
      marginBottom: "8px",
    }}>
      {/* Tier Header */}
      <div style={{
        padding: "20px 20px 10px 20px",
        display: "flex",
        alignItems: "center",
        gap: "8px",
      }}>
        <div style={{
          width: "20px",
          height: "2px",
          background: `linear-gradient(90deg, ${config.accentColor}50, transparent)`,
          borderRadius: "1px",
        }} />
        <span style={{
          fontFamily: "'DM Sans', 'Avenir', sans-serif",
          fontSize: "11px",
          fontWeight: 700,
          letterSpacing: "0.12em",
          color: config.accentColor,
        }}>
          {config.label}
        </span>
        <div style={{
          flex: 1,
          height: "1px",
          background: `linear-gradient(90deg, ${config.accentColor}20, transparent)`,
        }} />
        <span style={{
          fontFamily: "'DM Sans', 'Avenir', sans-serif",
          fontSize: "10px",
          color: config.accentColor + "80",
          fontWeight: 500,
        }}>
          {tierCourses.length}
        </span>
      </div>

      {/* Tier Background Zone */}
      <div style={{
        background: config.bgGradient,
        borderRadius: "4px",
        margin: "0 4px",
        padding: "4px 0",
      }}>
        {tierCourses.map((course, i) => (
          <CourseRow
            key={course.rank}
            course={course}
            isFirst={course.rank === 1}
          />
        ))}
      </div>
    </div>
  );
}

export default function FrontNineRankings() {
  const tiers = ["loved", "liked", "didnt_love"];

  return (
    <div style={{
      maxWidth: "390px",
      margin: "0 auto",
      background: "#FAFAF6",
      minHeight: "100vh",
      fontFamily: "'DM Sans', 'Avenir', -apple-system, sans-serif",
      position: "relative",
      borderLeft: "1px solid #eee",
      borderRight: "1px solid #eee",
    }}>
      {/* Import Fonts */}
      <link
        href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@300;400;500&family=DM+Sans:wght@400;500;600;700&display=swap"
        rel="stylesheet"
      />

      {/* Status Bar Spacer */}
      <div style={{ height: "52px" }} />

      {/* Top Bar */}
      <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "0 20px 4px 20px",
      }}>
        <button style={{
          background: "transparent",
          border: "1px solid rgba(0,0,0,0.1)",
          borderRadius: "18px",
          padding: "6px 16px",
          fontFamily: "'DM Sans', 'Avenir', sans-serif",
          fontSize: "14px",
          color: "#5A5348",
          cursor: "pointer",
          fontWeight: 500,
        }}>
          Edit
        </button>
        <div style={{ display: "flex", gap: "12px", alignItems: "center" }}>
          <button style={{
            background: "transparent",
            border: "none",
            fontSize: "26px",
            color: "#5A5348",
            cursor: "pointer",
            padding: "4px",
            lineHeight: 1,
          }}>
            +
          </button>
        </div>
      </div>

      {/* Title */}
      <div style={{
        padding: "8px 20px 4px 20px",
      }}>
        <h1 style={{
          fontFamily: "'Playfair Display', Georgia, serif",
          fontSize: "34px",
          fontWeight: 500,
          color: "#2C2C2C",
          margin: 0,
          letterSpacing: "-0.02em",
          lineHeight: 1.1,
        }}>
          My Rankings
        </h1>
        <p style={{
          fontFamily: "'DM Sans', 'Avenir', sans-serif",
          fontSize: "13px",
          color: "#A09890",
          margin: "6px 0 0 0",
          letterSpacing: "0.02em",
        }}>
          {courses.length} courses ranked
        </p>
      </div>

      {/* Tier Sections */}
      <div style={{ paddingBottom: "40px" }}>
        {tiers.map(tier => {
          const tierCourses = courses.filter(c => c.tier === tier);
          if (tierCourses.length === 0) return null;
          return (
            <TierSection
              key={tier}
              tier={tier}
              tierCourses={tierCourses}
            />
          );
        })}
      </div>
    </div>
  );
}
