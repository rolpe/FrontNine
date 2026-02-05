import React from 'react';

const mockCourses = [
  { rank: 1, name: "Pebble Beach Golf Links", city: "Pebble Beach", state: "CA", sentiment: "loved" },
  { rank: 2, name: "Pinehurst No. 2", city: "Pinehurst", state: "NC", sentiment: "loved" },
  { rank: 3, name: "Bandon Dunes", city: "Bandon", state: "OR", sentiment: "loved" },
  { rank: 4, name: "Bethpage Black", city: "Farmingdale", state: "NY", sentiment: "liked" },
  { rank: 5, name: "TPC Sawgrass", city: "Ponte Vedra Beach", state: "FL", sentiment: "liked" },
  { rank: 6, name: "Torrey Pines South", city: "La Jolla", state: "CA", sentiment: "liked" },
  { rank: 7, name: "Whistling Straits", city: "Kohler", state: "WI", sentiment: "liked" },
  { rank: 8, name: "Chambers Bay", city: "University Place", state: "WA", sentiment: "disliked" },
];

const colors = {
  cream: '#FAF8F5',
  text: '#2C2C2C',
  textLight: '#6B6360',
  sage: '#7D9A78',
  tan: '#D4C4B0',
  coral: '#E8A598',
  warmGray: '#A0938A',
};

const FlagIcon = ({ variant, color, size = 16 }) => {
  if (variant === 'filled') return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 4V21" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
      <path d="M5 4C5 4 6.5 3 9.5 3C12.5 3 14 5 17 5C18.5 5 19.5 4.5 20 4V14C19.5 14.5 18.5 15 17 15C14 15 12.5 13 9.5 13C6.5 13 5 14 5 14"
        fill={color} fillOpacity="0.25" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
  if (variant === 'outlined') return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 4V21" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
      <path d="M5 4C5 4 6.5 3 9.5 3C12.5 3 14 5 17 5C18.5 5 19.5 4.5 20 4V14C19.5 14.5 18.5 15 17 15C14 15 12.5 13 9.5 13C6.5 13 5 14 5 14"
        fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 4V21" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
      <path d="M5 4C5 4 6.5 3 9.5 3C12.5 3 14 5 17 5C18.5 5 19.5 4.5 20 4V14C19.5 14.5 18.5 15 17 15C14 15 12.5 13 9.5 13C6.5 13 5 14 5 14"
        fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" strokeDasharray="3 3" />
    </svg>
  );
};

const CourseRow = ({ course, color }) => (
  <div style={{
    display: 'flex',
    alignItems: 'center',
    padding: '16px 0',
    borderBottom: `1px solid ${colors.tan}40`,
  }}>
    <div style={{
      fontSize: '24px',
      fontWeight: '300',
      color: colors.tan,
      width: '44px',
      flexShrink: 0
    }}>
      {course.rank}
    </div>
    <div style={{
      width: '3px',
      height: '36px',
      backgroundColor: color,
      borderRadius: '2px',
      marginRight: '14px',
      flexShrink: 0
    }} />
    <div style={{ flex: 1 }}>
      <div style={{
        fontSize: '17px',
        color: colors.text,
        fontWeight: '500',
        marginBottom: '2px'
      }}>
        {course.name}
      </div>
      <div style={{
        fontSize: '14px',
        color: colors.textLight
      }}>
        {course.city}, {course.state}
      </div>
    </div>
  </div>
);

const TierSection = ({ title, courses, color, flag }) => (
  <div style={{ marginBottom: '32px' }}>
    <div style={{
      display: 'flex',
      alignItems: 'center',
      gap: '6px',
      marginBottom: '8px',
    }}>
      <FlagIcon variant={flag} color={color} />
      <span style={{
        fontSize: '13px',
        fontWeight: '600',
        color: color,
        textTransform: 'uppercase',
        letterSpacing: '0.5px',
      }}>
        {title}
      </span>
    </div>
    {courses.map((course) => (
      <CourseRow key={course.rank} course={course} color={color} />
    ))}
  </div>
);

const RankingsScreen = () => {
  const loved = mockCourses.filter(c => c.sentiment === 'loved');
  const liked = mockCourses.filter(c => c.sentiment === 'liked');
  const disliked = mockCourses.filter(c => c.sentiment === 'disliked');

  return (
    <div style={{
      backgroundColor: colors.cream,
      minHeight: '100%',
      padding: '20px 16px',
      fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif'
    }}>
      <h1 style={{
        fontSize: '28px',
        fontWeight: '600',
        color: colors.text,
        marginBottom: '32px',
        letterSpacing: '-0.5px'
      }}>
        My Rankings
      </h1>

      {loved.length > 0 && (
        <TierSection title="Loved" courses={loved} color={colors.coral} flag="filled" />
      )}
      {liked.length > 0 && (
        <TierSection title="Liked" courses={liked} color={colors.sage} flag="outlined" />
      )}
      {disliked.length > 0 && (
        <TierSection title="Didn't Love" courses={disliked} color={colors.warmGray} flag="dashed" />
      )}
    </div>
  );
};

export default function RankingsTierFlagsMockup() {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      height: '100vh',
      backgroundColor: '#E8E4E0',
      fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif'
    }}>
      {/* Header */}
      <div style={{
        padding: '16px 24px',
        backgroundColor: '#fff',
        borderBottom: '1px solid #ddd'
      }}>
        <h2 style={{ margin: 0, fontSize: '16px', color: colors.text }}>
          Front Nine — Rankings with Tier Flags
        </h2>
        <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: colors.textLight }}>
          Flag icon appears once per tier, next to the section header
        </p>
      </div>

      {/* Phone frame */}
      <div style={{
        flex: 1,
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        padding: '20px'
      }}>
        <div style={{
          width: '375px',
          height: '700px',
          borderRadius: '40px',
          overflow: 'hidden',
          boxShadow: '0 25px 50px rgba(0,0,0,0.15)',
          border: '8px solid #1a1a1a',
          backgroundColor: colors.cream
        }}>
          {/* Dynamic Island */}
          <div style={{
            height: '47px',
            backgroundColor: colors.cream,
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'flex-end',
            paddingBottom: '8px'
          }}>
            <div style={{
              width: '120px',
              height: '28px',
              backgroundColor: '#1a1a1a',
              borderRadius: '20px'
            }} />
          </div>

          {/* Screen content */}
          <div style={{
            height: 'calc(100% - 47px)',
            overflow: 'auto'
          }}>
            <RankingsScreen />
          </div>
        </div>
      </div>

      {/* Legend */}
      <div style={{
        padding: '16px 24px',
        backgroundColor: '#fff',
        borderTop: '1px solid #ddd',
        display: 'flex',
        gap: '24px',
        alignItems: 'center'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <FlagIcon variant="filled" color={colors.coral} size={14} />
          <span style={{ fontSize: '13px', color: colors.textLight }}>Loved</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <FlagIcon variant="outlined" color={colors.sage} size={14} />
          <span style={{ fontSize: '13px', color: colors.textLight }}>Liked</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <FlagIcon variant="dashed" color={colors.warmGray} size={14} />
          <span style={{ fontSize: '13px', color: colors.textLight }}>Didn't Love</span>
        </div>
      </div>
    </div>
  );
}
