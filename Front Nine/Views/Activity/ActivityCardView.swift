//
//  ActivityCardView.swift
//  Front Nine

import SwiftUI

struct ActivityCardView: View {
    let item: ActivityItem
    let onUserTap: () -> Void
    let onCourseTap: () -> Void

    private var tierColor: Color {
        Rating(rawValue: item.courseRating)?.tierColor ?? FNColors.sage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User row — taps to user profile
            Button(action: onUserTap) {
                HStack(spacing: 10) {
                    ProfileAvatarView(
                        name: item.actorDisplayName,
                        photoURL: nil,
                        uid: item.actorUid,
                        size: 36
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        actionText
                            .font(.system(size: 15))
                            .foregroundStyle(FNColors.text)

                        Text(ActivityFeedViewModel.relativeTime(from: item.timestamp))
                            .font(FNFonts.subtext())
                            .foregroundStyle(FNColors.warmGray)
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Course card — taps to course detail
            Button(action: onCourseTap) {
                courseCard
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FNColors.tan, lineWidth: 1)
        )
    }

    // MARK: - Action Text

    private var actionText: some View {
        let action = item.type == .ranked ? "ranked a course" : "re-ranked a course"
        return Text("**\(item.actorDisplayName)** \(action)")
    }

    // MARK: - Course Card

    private var courseCard: some View {
        HStack(spacing: 0) {
            // Tier color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(tierColor.gradient)
                .frame(width: 4)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.courseName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(FNColors.text)
                        .lineLimit(1)

                    Text(item.courseLocationText)
                        .font(FNFonts.subtext())
                        .foregroundStyle(FNColors.textLight)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    sentimentBadge

                    rankBadge
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(FNColors.cream)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
    }

    private var sentimentBadge: some View {
        let descriptor = item.sentimentDescriptor
        let label = descriptor.isEmpty ? item.courseRating : descriptor
        return Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(tierColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(tierColor.opacity(0.12))
            )
    }

    @ViewBuilder
    private var rankBadge: some View {
        if item.type == .reRanked, let oldRank = item.oldRankPosition {
            let movedUp = oldRank > item.newRankPosition
            HStack(spacing: 3) {
                Image(systemName: movedUp ? "arrow.up" : "arrow.down")
                    .font(.system(size: 9, weight: .semibold))
                Text("#\(item.newRankPosition) from #\(oldRank)")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(movedUp ? FNColors.sage : FNColors.warmGray)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill((movedUp ? FNColors.sage : FNColors.warmGray).opacity(0.12))
            )
        } else {
            Text("#\(item.newRankPosition)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(FNColors.warmGray)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(FNColors.warmGray.opacity(0.12))
                )
        }
    }
}
