import React from 'react';
import { BarChart3, MessageSquare, Stethoscope, ShieldCheck, Activity } from 'lucide-react';

export type ActiveTab = 'admin' | 'support' | 'clinician';

interface NavbarProps {
  activeTab: ActiveTab;
  onTabChange: (tab: ActiveTab) => void;
  openTicketCount: number;
}

export const Navbar: React.FC<NavbarProps> = ({
  activeTab,
  onTabChange,
  openTicketCount,
}) => {
  return (
    <header className="glass-header">
      {/* Brand & Title */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
        <div
          style={{
            width: '42px',
            height: '42px',
            borderRadius: '12px',
            background: 'linear-gradient(135deg, #00D084 0%, #059669 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#070D09',
            boxShadow: '0 0 20px rgba(0, 208, 132, 0.35)',
          }}
        >
          <Activity size={24} strokeWidth={2.4} />
        </div>
        <div>
          <h1 style={{ fontSize: '1.15rem', fontWeight: 800, color: '#FFFFFF', letterSpacing: '-0.02em', margin: 0 }}>
            Wellnest Cloud Console
          </h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '2px' }}>
            <span style={{ fontSize: '0.7rem', fontWeight: 700, color: '#00D084', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              Firebase Data Cloud
            </span>
            <span style={{ color: 'rgba(255,255,255,0.2)', fontSize: '0.7rem' }}>•</span>
            <span style={{ fontSize: '0.7rem', color: '#9CA3AF' }}>Vercel Edge Ready</span>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <nav
        style={{
          display: 'flex',
          backgroundColor: 'rgba(0, 0, 0, 0.35)',
          padding: '4px',
          borderRadius: '999px',
          border: '1px solid rgba(255, 255, 255, 0.08)',
          gap: '4px',
        }}
      >
        <button
          onClick={() => onTabChange('admin')}
          style={{
            background: activeTab === 'admin' ? 'rgba(0, 208, 132, 0.16)' : 'transparent',
            border: activeTab === 'admin' ? '1px solid rgba(0, 208, 132, 0.35)' : '1px solid transparent',
            color: activeTab === 'admin' ? '#00D084' : '#9CA3AF',
            fontFamily: 'inherit',
            fontSize: '0.88rem',
            fontWeight: 600,
            padding: '8px 18px',
            borderRadius: '999px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'all 0.2s',
          }}
        >
          <BarChart3 size={16} />
          Admin Intelligence
        </button>

        <button
          onClick={() => onTabChange('support')}
          style={{
            background: activeTab === 'support' ? 'rgba(0, 208, 132, 0.16)' : 'transparent',
            border: activeTab === 'support' ? '1px solid rgba(0, 208, 132, 0.35)' : '1px solid transparent',
            color: activeTab === 'support' ? '#00D084' : '#9CA3AF',
            fontFamily: 'inherit',
            fontSize: '0.88rem',
            fontWeight: 600,
            padding: '8px 18px',
            borderRadius: '999px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'all 0.2s',
          }}
        >
          <MessageSquare size={16} />
          Support & Live Chat
          {openTicketCount > 0 && (
            <span
              style={{
                backgroundColor: '#00D084',
                color: '#070D09',
                fontSize: '0.68rem',
                fontWeight: 800,
                padding: '1px 7px',
                borderRadius: '999px',
              }}
            >
              {openTicketCount}
            </span>
          )}
        </button>

        <button
          onClick={() => onTabChange('clinician')}
          style={{
            background: activeTab === 'clinician' ? 'rgba(0, 208, 132, 0.16)' : 'transparent',
            border: activeTab === 'clinician' ? '1px solid rgba(0, 208, 132, 0.35)' : '1px solid transparent',
            color: activeTab === 'clinician' ? '#00D084' : '#9CA3AF',
            fontFamily: 'inherit',
            fontSize: '0.88rem',
            fontWeight: 600,
            padding: '8px 18px',
            borderRadius: '999px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'all 0.2s',
          }}
        >
          <Stethoscope size={16} />
          Doctor Pair Access
        </button>
      </nav>

      {/* Right Badges */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            backgroundColor: 'rgba(0, 208, 132, 0.08)',
            border: '1px solid rgba(0, 208, 132, 0.25)',
            padding: '6px 14px',
            borderRadius: '999px',
            fontSize: '0.75rem',
            fontWeight: 600,
            color: '#00D084',
          }}
        >
          <ShieldCheck size={14} />
          <span>Privacy Isolation Active</span>
          <span className="pulse-dot" />
        </div>

        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            backgroundColor: 'rgba(255, 255, 255, 0.05)',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            padding: '4px 12px 4px 4px',
            borderRadius: '999px',
            fontSize: '0.82rem',
            fontWeight: 600,
          }}
        >
          <div
            style={{
              width: '30px',
              height: '30px',
              borderRadius: '50%',
              background: 'linear-gradient(135deg, #10B981, #047857)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '0.72rem',
              fontWeight: 700,
              color: '#FFF',
            }}
          >
            AD
          </div>
          <span>Admin</span>
        </div>
      </div>
    </header>
  );
};
