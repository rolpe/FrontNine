import React, { useState } from 'react';

const colors = {
  cream: '#FAF8F5',
  text: '#2C2C2C',
  textLight: '#6B6360',
  sage: '#7D9A78',
  tan: '#D4C4B0',
  coral: '#E8A598',
  warmGray: '#A0938A',
  white: '#FFFFFF',
};

const AddCourseScreen = () => {
  const [courseName, setCourseName] = useState('');
  const [city, setCity] = useState('');
  const [state, setState] = useState('');
  const [courseType, setCourseType] = useState('');
  const [holes, setHoles] = useState(18);
  const [rating, setRating] = useState(null);
  
  const courseTypes = ['Public', 'Private'];
  const holeOptions = [9, 18];
  const ratings = [
    { value: 'loved', emoji: '😍', label: 'Loved it' },
    { value: 'liked', emoji: '👍', label: 'Liked it' },
    { value: 'disliked', emoji: '👎', label: "Didn't love it" },
  ];
  
  const inputStyle = {
    width: '100%',
    padding: '14px 16px',
    fontSize: '17px',
    border: `1.5px solid ${colors.tan}`,
    borderRadius: '12px',
    backgroundColor: colors.white,
    color: colors.text,
    outline: 'none',
    boxSizing: 'border-box',
    fontFamily: 'inherit',
  };
  
  const labelStyle = {
    fontSize: '13px',
    fontWeight: '600',
    color: colors.textLight,
    marginBottom: '8px',
    display: 'block',
    textTransform: 'uppercase',
    letterSpacing: '0.3px',
  };
  
  const canSubmit = courseName && city && state && courseType && rating;
  
  return (
    <div style={{ 
      backgroundColor: colors.cream, 
      minHeight: '100%',
      fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
      display: 'flex',
      flexDirection: 'column',
    }}>
      {/* Header */}
      <div style={{
        padding: '16px 20px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        borderBottom: `1px solid ${colors.tan}40`,
      }}>
        <button style={{
          background: 'none',
          border: 'none',
          fontSize: '17px',
          color: colors.textLight,
          cursor: 'pointer',
          padding: '4px 0',
        }}>
          Cancel
        </button>
        <h1 style={{ 
          fontSize: '17px', 
          fontWeight: '600', 
          color: colors.text,
          margin: 0,
        }}>
          Add Course
        </h1>
        <div style={{ width: '50px' }} /> {/* Spacer for centering */}
      </div>
      
      {/* Form */}
      <div style={{
        flex: 1,
        padding: '24px 20px',
        overflowY: 'auto',
      }}>
        {/* Course Name */}
        <div style={{ marginBottom: '24px' }}>
          <label style={labelStyle}>Course Name</label>
          <input
            type="text"
            placeholder="e.g. Pebble Beach Golf Links"
            value={courseName}
            onChange={(e) => setCourseName(e.target.value)}
            style={inputStyle}
          />
        </div>
        
        {/* City & State row */}
        <div style={{ 
          display: 'flex', 
          gap: '12px',
          marginBottom: '24px'
        }}>
          <div style={{ flex: 2 }}>
            <label style={labelStyle}>City</label>
            <input
              type="text"
              placeholder="City"
              value={city}
              onChange={(e) => setCity(e.target.value)}
              style={inputStyle}
            />
          </div>
          <div style={{ flex: 1 }}>
            <label style={labelStyle}>State</label>
            <input
              type="text"
              placeholder="CA"
              value={state}
              onChange={(e) => setState(e.target.value)}
              style={inputStyle}
            />
          </div>
        </div>
        
        {/* Course Type */}
        <div style={{ marginBottom: '24px' }}>
          <label style={labelStyle}>Course Type</label>
          <div style={{ 
            display: 'flex', 
            gap: '8px',
            flexWrap: 'wrap'
          }}>
            {courseTypes.map((type) => (
              <button
                key={type}
                onClick={() => setCourseType(type)}
                style={{
                  padding: '10px 16px',
                  fontSize: '15px',
                  border: `1.5px solid ${courseType === type ? colors.sage : colors.tan}`,
                  borderRadius: '20px',
                  backgroundColor: courseType === type ? colors.sage : colors.white,
                  color: courseType === type ? colors.white : colors.text,
                  cursor: 'pointer',
                  fontWeight: '500',
                  transition: 'all 0.15s ease',
                }}
              >
                {type}
              </button>
            ))}
          </div>
        </div>
        
        {/* Holes */}
        <div style={{ marginBottom: '32px' }}>
          <label style={labelStyle}>Holes</label>
          <div style={{ 
            display: 'flex', 
            gap: '8px',
          }}>
            {holeOptions.map((num) => (
              <button
                key={num}
                onClick={() => setHoles(num)}
                style={{
                  padding: '10px 20px',
                  fontSize: '15px',
                  border: `1.5px solid ${holes === num ? colors.sage : colors.tan}`,
                  borderRadius: '20px',
                  backgroundColor: holes === num ? colors.sage : colors.white,
                  color: holes === num ? colors.white : colors.text,
                  cursor: 'pointer',
                  fontWeight: '500',
                  transition: 'all 0.15s ease',
                }}
              >
                {num}
              </button>
            ))}
          </div>
        </div>
        
        {/* Divider */}
        <div style={{
          height: '1px',
          backgroundColor: colors.tan,
          margin: '8px 0 32px 0',
        }} />
        
        {/* Rating */}
        <div style={{ marginBottom: '24px' }}>
          <label style={labelStyle}>How was it?</label>
          <div style={{ 
            display: 'flex', 
            flexDirection: 'column',
            gap: '10px',
          }}>
            {ratings.map((r) => (
              <button
                key={r.value}
                onClick={() => setRating(r.value)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '14px',
                  padding: '16px',
                  fontSize: '17px',
                  border: `1.5px solid ${rating === r.value 
                    ? (r.value === 'loved' ? colors.coral : r.value === 'liked' ? colors.sage : colors.warmGray)
                    : colors.tan}`,
                  borderRadius: '12px',
                  backgroundColor: rating === r.value 
                    ? (r.value === 'loved' ? `${colors.coral}15` : r.value === 'liked' ? `${colors.sage}15` : `${colors.warmGray}15`)
                    : colors.white,
                  color: colors.text,
                  cursor: 'pointer',
                  fontWeight: '500',
                  transition: 'all 0.15s ease',
                  textAlign: 'left',
                }}
              >
                <span style={{ fontSize: '24px' }}>{r.emoji}</span>
                <span>{r.label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>
      
      {/* Submit button */}
      <div style={{
        padding: '16px 20px 32px 20px',
        borderTop: `1px solid ${colors.tan}40`,
      }}>
        <button
          disabled={!canSubmit}
          style={{
            width: '100%',
            padding: '16px',
            fontSize: '17px',
            fontWeight: '600',
            border: 'none',
            borderRadius: '12px',
            backgroundColor: canSubmit ? colors.sage : colors.tan,
            color: canSubmit ? colors.white : colors.textLight,
            cursor: canSubmit ? 'pointer' : 'not-allowed',
            transition: 'all 0.15s ease',
          }}
        >
          Add & Rank This Course
        </button>
      </div>
    </div>
  );
};

export default function AddCourseMockup() {
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
          Front Nine — Add Course Screen
        </h2>
        <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: colors.textLight }}>
          Interactive — try filling out the form
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
          height: '750px',
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
            overflow: 'hidden',
            display: 'flex',
            flexDirection: 'column'
          }}>
            <AddCourseScreen />
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
          <strong style={{ color: colors.text }}>Flow:</strong> Fill out details → select rating → "Add & Rank" triggers comparison flow (if other courses exist in tier).
        </p>
      </div>
    </div>
  );
}
