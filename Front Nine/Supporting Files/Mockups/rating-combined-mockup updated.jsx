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

const FlagIcon = ({ variant, color, size = 22 }) => {
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
  // dashed
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 4V21" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
      <path d="M5 4C5 4 6.5 3 9.5 3C12.5 3 14 5 17 5C18.5 5 19.5 4.5 20 4V14C19.5 14.5 18.5 15 17 15C14 15 12.5 13 9.5 13C6.5 13 5 14 5 14"
        fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" strokeDasharray="3 3" />
    </svg>
  );
};

const ratingOptions = [
  { key: 'loved', color: colors.coral, label: 'Loved it', flag: 'filled' },
  { key: 'liked', color: colors.sage, label: 'Liked it', flag: 'outlined' },
  { key: 'disliked', color: colors.warmGray, label: "Didn't love it", flag: 'dashed' },
];

const RatingPicker = ({ selected, onSelect }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
    {ratingOptions.map(({ key, color, label, flag }) => {
      const isSelected = selected === key;
      return (
        <button
          key={key}
          onClick={() => onSelect(key)}
          style={{
            display: 'flex',
            alignItems: 'center',
            padding: '0',
            fontSize: '17px',
            border: `1.5px solid ${isSelected ? color : colors.tan}`,
            borderRadius: '12px',
            backgroundColor: isSelected ? `${color}12` : colors.white,
            color: colors.text,
            cursor: 'pointer',
            fontWeight: '500',
            transition: 'all 0.15s ease',
            textAlign: 'left',
            overflow: 'hidden',
          }}
        >
          <div style={{
            width: '4px',
            alignSelf: 'stretch',
            backgroundColor: color,
            flexShrink: 0,
          }} />
          <span style={{ padding: '16px', flex: 1 }}>{label}</span>
          <div style={{ paddingRight: '16px', display: 'flex', alignItems: 'center' }}>
            <FlagIcon variant={flag} color={color} />
          </div>
        </button>
      );
    })}
  </div>
);

export default function CombinedRatingMockup() {
  const [selected, setSelected] = useState('liked');

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
        borderBottom: '1px solid #ddd',
      }}>
        <h2 style={{ margin: 0, fontSize: '16px', color: colors.text }}>
          Front Nine — Rating Picker: Color Bar + Golf Flags
        </h2>
        <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: colors.textLight }}>
          Tap to see selection states
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
          height: '580px',
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
            padding: '24px 20px',
            display: 'flex',
            flexDirection: 'column',
          }}>
            {/* Fake form fields above for context */}
            <div style={{ marginBottom: '10px', opacity: 0.35 }}>
              <div style={{
                height: '44px',
                borderRadius: '12px',
                border: `1.5px solid ${colors.tan}`,
                backgroundColor: colors.white,
                display: 'flex',
                alignItems: 'center',
                padding: '0 16px',
                fontSize: '17px',
                color: colors.textLight,
                marginBottom: '10px',
              }}>
                Pebble Beach Golf Links
              </div>
              <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
                <div style={{
                  flex: 2,
                  height: '44px',
                  borderRadius: '12px',
                  border: `1.5px solid ${colors.tan}`,
                  backgroundColor: colors.white,
                  display: 'flex',
                  alignItems: 'center',
                  padding: '0 16px',
                  fontSize: '17px',
                  color: colors.textLight,
                }}>
                  Pebble Beach
                </div>
                <div style={{
                  flex: 1,
                  height: '44px',
                  borderRadius: '12px',
                  border: `1.5px solid ${colors.tan}`,
                  backgroundColor: colors.white,
                  display: 'flex',
                  alignItems: 'center',
                  padding: '0 16px',
                  fontSize: '17px',
                  color: colors.textLight,
                }}>
                  CA
                </div>
              </div>
            </div>

            {/* Divider */}
            <div style={{
              height: '1px',
              backgroundColor: colors.tan,
              margin: '12px 0 24px 0',
            }} />

            {/* Rating label */}
            <label style={{
              fontSize: '13px',
              fontWeight: '600',
              color: colors.textLight,
              marginBottom: '12px',
              display: 'block',
              textTransform: 'uppercase',
              letterSpacing: '0.3px',
            }}>
              How was it?
            </label>

            {/* Rating picker */}
            <RatingPicker selected={selected} onSelect={setSelected} />

            {/* Submit button */}
            <button
              style={{
                marginTop: '28px',
                width: '100%',
                padding: '16px',
                fontSize: '17px',
                fontWeight: '600',
                border: 'none',
                borderRadius: '12px',
                backgroundColor: selected ? colors.sage : colors.tan,
                color: selected ? colors.white : colors.textLight,
                cursor: selected ? 'pointer' : 'not-allowed',
                transition: 'all 0.15s ease',
              }}
            >
              Add & Rank This Course
            </button>
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
          <strong style={{ color: colors.text }}>Color bar + right-aligned flags:</strong>{' '}
          Filled flag = Loved, outlined = Liked, dashed = Didn't Love. The bar anchors the left, the flag is a subtle reinforcement on the right.
        </p>
      </div>
    </div>
  );
}
