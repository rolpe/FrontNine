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

const TierSection = ({ title, courses, color }) => (
  <div style={{ marginBottom: '32px' }}>
    <div style={{
      fontSize: '13px',
      fontWeight: '600',
      color: color,
      textTransform: 'uppercase',
      letterSpacing: '0.5px',
      marginBottom: '8px'
    }}>
      {title}
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
        <TierSection title="Loved" courses={loved} color={colors.coral} />
      )}
      {liked.length > 0 && (
        <TierSection title="Liked" courses={liked} color={colors.sage} />
      )}
      {disliked.length > 0 && (
        <TierSection title="Didn't Love" courses={disliked} color={colors.warmGray} />
      )}
    </div>
  );
};

export default function RankingsMockup() {
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
          Front Nine — Rankings Screen
        </h2>
        <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: colors.textLight }}>
          Grouped by tier + rank emphasis styling
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
      
      {/* Design notes */}
      <div style={{
        padding: '16px 24px',
        backgroundColor: '#fff',
        borderTop: '1px solid #ddd',
        display: 'flex',
        gap: '24px',
        flexWrap: 'wrap'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div style={{ width: '12px', height: '12px', borderRadius: '2px', backgroundColor: colors.coral }} />
          <span style={{ fontSize: '13px', color: colors.textLight }}>Loved</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div style={{ width: '12px', height: '12px', borderRadius: '2px', backgroundColor: colors.sage }} />
          <span style={{ fontSize: '13px', color: colors.textLight }}>Liked</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div style={{ width: '12px', height: '12px', borderRadius: '2px', backgroundColor: colors.warmGray }} />
          <span style={{ fontSize: '13px', color: colors.textLight }}>Didn't Love</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginLeft: 'auto' }}>
          <span style={{ fontSize: '13px', color: colors.textLight }}>Background: {colors.cream}</span>
        </div>
      </div>
    </div>
  );
}
