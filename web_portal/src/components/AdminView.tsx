import React, { useState } from 'react';
import { Users, UserCheck, UserX, Crown, Shield, Search, ArrowUpRight } from 'lucide-react';
import { ConcentricRingChart } from './charts/ConcentricRingChart';
import { PolygonRadarChart } from './charts/PolygonRadarChart';
import { ADMIN_KPIS, RADAR_DATA, INITIAL_USERS } from '../services/data';
import { UserAccount } from '../types';

export const AdminView: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [users] = useState<UserAccount[]>(INITIAL_USERS);

  const filteredUsers = users.filter(u =>
    u.accountIdentifier.toLowerCase().includes(searchTerm.toLowerCase()) ||
    u.plan.toLowerCase().includes(searchTerm.toLowerCase()) ||
    u.platform.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const formatRelativeTime = (isoString: string) => {
    const diffMs = Date.now() - new Date(isoString).getTime();
    const diffMins = Math.floor(diffMs / (1000 * 60));
    if (diffMins < 60) return `${diffMins}m ago`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours}h ago`;
    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays}d ago`;
  };

  return (
    <div className="tab-enter" style={{ display: 'flex', flexDirection: 'column', gap: '28px' }}>
      {/* Privacy Isolation Banner */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '16px',
          background: 'rgba(16, 185, 129, 0.08)',
          border: '1px solid rgba(16, 185, 129, 0.22)',
          borderRadius: '16px',
          padding: '16px 22px',
          color: '#D1FAE5',
          fontSize: '0.88rem',
          lineHeight: 1.5,
        }}
      >
        <Shield size={26} color="#00D084" style={{ flexShrink: 0 }} />
        <div>
          <strong style={{ color: '#FFFFFF' }}>Privacy-by-Design Architecture Active:</strong>{' '}
          Personal biometric telemetry, clinical journals, and reproductive health logs are stored in zero-knowledge client silos.
          The Admin console strictly monitors aggregate infrastructure health, subscription ratios, and anonymous telemetry distributions.
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
          gap: '20px',
        }}
      >
        {/* Total Users */}
        <div className="glass-card" style={{ display: 'flex', alignItems: 'center', gap: '18px' }}>
          <div
            style={{
              width: '52px',
              height: '52px',
              borderRadius: '14px',
              backgroundColor: 'rgba(56, 189, 248, 0.12)',
              color: '#38BDF8',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <Users size={24} />
          </div>
          <div>
            <div style={{ fontSize: '0.72rem', fontWeight: 700, color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              TOTAL REGISTERED USERS
            </div>
            <div style={{ fontSize: '1.9rem', fontWeight: 800, color: '#FFFFFF', letterSpacing: '-0.03em' }}>
              {ADMIN_KPIS.totalUsers.toLocaleString()}
            </div>
            <div style={{ fontSize: '0.76rem', color: '#00D084', display: 'flex', alignItems: 'center', gap: '2px', fontWeight: 600 }}>
              <ArrowUpRight size={14} /> +14.2% this month
            </div>
          </div>
        </div>

        {/* Active Users */}
        <div className="glass-card" style={{ display: 'flex', alignItems: 'center', gap: '18px' }}>
          <div
            style={{
              width: '52px',
              height: '52px',
              borderRadius: '14px',
              backgroundColor: 'rgba(0, 208, 132, 0.12)',
              color: '#00D084',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <UserCheck size={24} />
          </div>
          <div>
            <div style={{ fontSize: '0.72rem', fontWeight: 700, color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              ACTIVE USERS (7-DAY)
            </div>
            <div style={{ fontSize: '1.9rem', fontWeight: 800, color: '#FFFFFF', letterSpacing: '-0.03em' }}>
              {ADMIN_KPIS.activeUsers7D.toLocaleString()}
            </div>
            <div style={{ fontSize: '0.76rem', color: '#00D084', fontWeight: 600 }}>
              {ADMIN_KPIS.activePercent}% platform retention
            </div>
          </div>
        </div>

        {/* Inactive Users */}
        <div className="glass-card" style={{ display: 'flex', alignItems: 'center', gap: '18px' }}>
          <div
            style={{
              width: '52px',
              height: '52px',
              borderRadius: '14px',
              backgroundColor: 'rgba(156, 163, 175, 0.12)',
              color: '#9CA3AF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <UserX size={24} />
          </div>
          <div>
            <div style={{ fontSize: '0.72rem', fontWeight: 700, color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              INACTIVE USERS (&gt;30D)
            </div>
            <div style={{ fontSize: '1.9rem', fontWeight: 800, color: '#FFFFFF', letterSpacing: '-0.03em' }}>
              {ADMIN_KPIS.inactiveUsers.toLocaleString()}
            </div>
            <div style={{ fontSize: '0.76rem', color: '#9CA3AF', fontWeight: 600 }}>
              {(100 - ADMIN_KPIS.activePercent).toFixed(1)}% dormant
            </div>
          </div>
        </div>

        {/* Premium vs Freemium */}
        <div className="glass-card" style={{ display: 'flex', alignItems: 'center', gap: '18px' }}>
          <div
            style={{
              width: '52px',
              height: '52px',
              borderRadius: '14px',
              backgroundColor: 'rgba(245, 158, 11, 0.12)',
              color: '#F59E0B',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <Crown size={24} />
          </div>
          <div>
            <div style={{ fontSize: '0.72rem', fontWeight: 700, color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              PREMIUM VS FREEMIUM
            </div>
            <div style={{ fontSize: '1.9rem', fontWeight: 800, color: '#FFFFFF', letterSpacing: '-0.03em' }}>
              {ADMIN_KPIS.premiumUsers}{' '}
              <span style={{ fontSize: '1.1rem', fontWeight: 600, color: '#6B7280' }}>
                / {ADMIN_KPIS.freemiumUsers}
              </span>
            </div>
            <div style={{ fontSize: '0.76rem', color: '#F59E0B', fontWeight: 600 }}>
              {ADMIN_KPIS.premiumPercent}% paid conversion
            </div>
          </div>
        </div>
      </div>

      {/* Graphical Representations Grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(460px, 1fr))',
          gap: '24px',
        }}
      >
        {/* Ring Chart Card */}
        <div className="glass-card">
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: '18px' }}>
            <div>
              <h3 style={{ fontSize: '1.15rem', fontWeight: 700, color: '#FFFFFF', margin: 0 }}>
                Concentric Engagement Rings
              </h3>
              <p style={{ fontSize: '0.82rem', color: '#9CA3AF', margin: '4px 0 0 0' }}>
                Multi-layer ring visualizer showing active users, 7-day habit streaks, and Pro tier share
              </p>
            </div>
            <span
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.06)',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                padding: '4px 10px',
                borderRadius: '999px',
                fontSize: '0.72rem',
                color: '#9CA3AF',
                fontWeight: 600,
              }}
            >
              Interactive SVG
            </span>
          </div>

          <ConcentricRingChart
            activePercent={ADMIN_KPIS.activePercent}
            streakPercent={ADMIN_KPIS.streakPercent}
            premiumPercent={ADMIN_KPIS.premiumPercent}
          />
        </div>

        {/* Polygon Radar Chart Card */}
        <div className="glass-card">
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: '18px' }}>
            <div>
              <h3 style={{ fontSize: '1.15rem', fontWeight: 700, color: '#FFFFFF', margin: 0 }}>
                Multi-Axis Engagement Polygon
              </h3>
              <p style={{ fontSize: '0.82rem', color: '#9CA3AF', margin: '4px 0 0 0' }}>
                5-dimensional radar chart across cardiac vitals, hydration, mobility, nutrition, and sleep
              </p>
            </div>
            <span
              style={{
                backgroundColor: 'rgba(0, 208, 132, 0.1)',
                border: '1px solid rgba(0, 208, 132, 0.25)',
                padding: '4px 10px',
                borderRadius: '999px',
                fontSize: '0.72rem',
                color: '#00D084',
                fontWeight: 600,
              }}
            >
              Radar Polygon
            </span>
          </div>

          <PolygonRadarChart data={RADAR_DATA} />
        </div>
      </div>

      {/* User Accounts Activity Table */}
      <div className="glass-card" style={{ padding: '24px' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: '20px',
            flexWrap: 'wrap',
            gap: '12px',
          }}
        >
          <div>
            <h3 style={{ fontSize: '1.15rem', fontWeight: 700, color: '#FFFFFF', margin: 0 }}>
              User Accounts &amp; Telemetry Activity
            </h3>
            <p style={{ fontSize: '0.82rem', color: '#9CA3AF', margin: '4px 0 0 0' }}>
              Anonymous account identifiers, subscription tier, platform, and last active timestamp
            </p>
          </div>

          {/* Search Box */}
          <div style={{ position: 'relative' }}>
            <Search
              size={16}
              color="#6B7280"
              style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)' }}
            />
            <input
              type="text"
              placeholder="Search by ID, plan, or OS..."
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
              style={{
                backgroundColor: 'rgba(0, 0, 0, 0.35)',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                color: '#FFFFFF',
                fontFamily: 'inherit',
                fontSize: '0.85rem',
                padding: '8px 16px 8px 38px',
                borderRadius: '999px',
                outline: 'none',
                width: '260px',
              }}
            />
          </div>
        </div>

        {/* Table */}
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.88rem' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid rgba(255, 255, 255, 0.08)' }}>
                <th style={{ padding: '12px 16px', fontSize: '0.72rem', color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Account Identifier
                </th>
                <th style={{ padding: '12px 16px', fontSize: '0.72rem', color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Plan Tier
                </th>
                <th style={{ padding: '12px 16px', fontSize: '0.72rem', color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Platform
                </th>
                <th style={{ padding: '12px 16px', fontSize: '0.72rem', color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Last Active
                </th>
                <th style={{ padding: '12px 16px', fontSize: '0.72rem', color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Status
                </th>
                <th style={{ padding: '12px 16px', fontSize: '0.72rem', color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  Joined Date
                </th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.map(user => (
                <tr
                  key={user.id}
                  style={{
                    borderBottom: '1px solid rgba(255, 255, 255, 0.03)',
                    transition: 'background-color 0.15s',
                  }}
                  onMouseEnter={e => (e.currentTarget.style.backgroundColor = 'rgba(255, 255, 255, 0.02)')}
                  onMouseLeave={e => (e.currentTarget.style.backgroundColor = 'transparent')}
                >
                  <td style={{ padding: '14px 16px', fontWeight: 700, color: '#FFFFFF', fontFamily: 'monospace' }}>
                    {user.accountIdentifier}
                  </td>
                  <td style={{ padding: '14px 16px' }}>
                    <span
                      style={{
                        display: 'inline-block',
                        padding: '3px 10px',
                        borderRadius: '999px',
                        fontSize: '0.72rem',
                        fontWeight: 700,
                        textTransform: 'uppercase',
                        backgroundColor: user.plan === 'premium' ? 'rgba(245, 158, 11, 0.15)' : 'rgba(255, 255, 255, 0.06)',
                        border: `1px solid ${user.plan === 'premium' ? 'rgba(245, 158, 11, 0.35)' : 'rgba(255, 255, 255, 0.08)'}`,
                        color: user.plan === 'premium' ? '#F59E0B' : '#9CA3AF',
                      }}
                    >
                      {user.plan}
                    </span>
                  </td>
                  <td style={{ padding: '14px 16px', color: '#D1D5DB', textTransform: 'capitalize' }}>
                    {user.platform} ({user.appBuild})
                  </td>
                  <td style={{ padding: '14px 16px', color: '#9CA3AF' }}>
                    {formatRelativeTime(user.lastActive)}
                  </td>
                  <td style={{ padding: '14px 16px' }}>
                    <span
                      style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: '6px',
                        padding: '3px 10px',
                        borderRadius: '999px',
                        fontSize: '0.74rem',
                        fontWeight: 600,
                        backgroundColor: user.status === 'active' ? 'rgba(0, 208, 132, 0.15)' : 'rgba(156, 163, 175, 0.15)',
                        border: `1px solid ${user.status === 'active' ? 'rgba(0, 208, 132, 0.3)' : 'rgba(156, 163, 175, 0.25)'}`,
                        color: user.status === 'active' ? '#00D084' : '#9CA3AF',
                      }}
                    >
                      <span
                        style={{
                          width: '6px',
                          height: '6px',
                          borderRadius: '50%',
                          backgroundColor: user.status === 'active' ? '#00D084' : '#9CA3AF',
                        }}
                      />
                      {user.status === 'active' ? 'Active' : 'Dormant'}
                    </span>
                  </td>
                  <td style={{ padding: '14px 16px', color: '#9CA3AF', fontSize: '0.8rem' }}>
                    {new Date(user.createdAt).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
