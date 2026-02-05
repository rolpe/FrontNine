import React, { useState } from 'react';

const colors = {
  cream: '#FAF8F5',
  text: '#2C2C2C',
  textLight: '#6B6360',
  sage: '#7D9A78',
  tan: '#D4C4B0',
  coral: '#E8A598',
  warmGray: '#A0938A',
};

// The new course being ranked
const newCourse = { 
  name: "Whistling Straits", 
  city: "Kohler", 
  state: "WI", 
  sentiment: "liked" 
};

// Course to compare against
const compareCourse = { 
  name: "TPC Sawgrass", 
  city: "Ponte Vedra Beach", 
  state: "FL", 
  sentiment: "liked" 
};

const ComparisonScreen = ({ selected, onSelect }) => {
  return (
    <div style={{ 
      backgroundColor: colors.cream, 
      minHeight: '100%',
      padding: '20px 16px',
      fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
      display: 'flex',
      flexDirection: 'column',
    }}>
      {/* Progress indicator */}
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        gap: '8px',
        marginBottom: '12px'
      }}>
        {[1, 2, 3].map((step) => (
          <div 
            key={step}
            style={{
              width: step === 2 ? '24px' : '8px',
              height: '8px',
              borderRadius: '4px',
              backgroundColor: step === 2 ? colors.sage : colors.tan,
              transition: 'all 0.2s ease'
            }} 
          />
        ))}
      </div>
      
      {/* Question */}
      <div style={{
        textAlign: 'center',
        marginBottom: '32px'
      }}>
        <h1 style={{ 
          fontSize: '24px', 
          fontWeight: '600', 
          color: colors.text,
          marginBottom: '8px',
          letterSpacing: '-0.3px'
        }}>
          Which would you rather play?
        </h1>
        <p style={{
          fontSize: '15px',
          color: colors.textLight,
          margin: 0
        }}>
          Tap your choice
        </p>
      </div>
      
      {/* Course cards */}
      <div style={{
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        gap: '16px',
        marginBottom: '24px'
      }}>
        {/* Card A */}
        <button
          onClick={() => onSelect('A')}
          style={{
            flex: 1,
            backgroundColor: selected === 'A' ? colors.sage : '#FFFFFF',
            border: `2px solid ${selected === 'A' ? colors.sage : colors.tan}`,
            borderRadius: '16px',
            padding: '24px',
            cursor: 'pointer',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            transition: 'all 0.15s ease',
            boxShadow: selected === 'A' 
              ? '0 4px 20px rgba(125, 154, 120, 0.3)' 
              : '0 2px 8px rgba(0,0,0,0.04)'
          }}
        >
          <div style={{ 
            fontSize: '22px', 
            fontWeight: '600', 
            color: selected === 'A' ? '#FFFFFF' : colors.text,
            marginBottom: '6px',
            textAlign: 'center'
          }}>
            {newCourse.name}
          </div>
          <div style={{ 
            fontSize: '16px', 
            color: selected === 'A' ? 'rgba(255,255,255,0.85)' : colors.textLight 
          }}>
            {newCourse.city}, {newCourse.state}
          </div>
        </button>
        
        {/* VS divider */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '16px'
        }}>
          <div style={{ 
            flex: 1, 
            height: '1px', 
            backgroundColor: colors.tan 
          }} />
          <span style={{ 
            fontSize: '13px', 
            fontWeight: '600',
            color: colors.tan,
            letterSpacing: '1px'
          }}>
            OR
          </span>
          <div style={{ 
            flex: 1, 
            height: '1px', 
            backgroundColor: colors.tan 
          }} />
        </div>
        
        {/* Card B */}
        <button
          onClick={() => onSelect('B')}
          style={{
            flex: 1,
            backgroundColor: selected === 'B' ? colors.sage : '#FFFFFF',
            border: `2px solid ${selected === 'B' ? colors.sage : colors.tan}`,
            borderRadius: '16px',
            padding: '24px',
            cursor: 'pointer',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            transition: 'all 0.15s ease',
            boxShadow: selected === 'B' 
              ? '0 4px 20px rgba(125, 154, 120, 0.3)' 
              : '0 2px 8px rgba(0,0,0,0.04)'
          }}
        >
          <div style={{ 
            fontSize: '22px', 
            fontWeight: '600', 
            color: selected === 'B' ? '#FFFFFF' : colors.text,
            marginBottom: '6px',
            textAlign: 'center'
          }}>
            {compareCourse.name}
          </div>
          <div style={{ 
            fontSize: '16px', 
            color: selected === 'B' ? 'rgba(255,255,255,0.85)' : colors.textLight 
          }}>
            {compareCourse.city}, {compareCourse.state}
          </div>
        </button>
      </div>
      
      {/* Can't decide link */}
      <button
        style={{
          background: 'none',
          border: 'none',
          padding: '12px',
          cursor: 'pointer',
          fontSize: '15px',
          color: colors.textLight,
          textAlign: 'center'
        }}
      >
        I can't decide
      </button>
    </div>
  );
};

export default function ComparisonMockup() {
  const [selected, setSelected] = useState(null);
  
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
          Front Nine — Comparison Screen
        </h2>
        <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: colors.textLight }}>
          Tap a card to see selection state
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
            <ComparisonScreen selected={selected} onSelect={setSelected} />
          </div>
        </div>
      </div>
      
      {/* Design notes */}
      <div style={{
        padding: '16px 24px',
        backgroundColor: '#fff',
        borderTop: '1px solid #ddd'
      }}>
        <p style={{ margin: 0, fontSize: '13px', color: colors.textLight }}>
          <strong style={{ color: colors.text }}>Interaction:</strong> Tap selects immediately and would advance to next comparison (or show final placement). Progress dots show current step.
        </p>
      </div>
    </div>
  );
}
