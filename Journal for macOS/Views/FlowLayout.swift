import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 10) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.height }.reduce(0, +) + spacing * CGFloat(rows.count - 1)
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            for element in row.elements {
                element.subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: element.width, height: row.height)
                )
                x += element.width + spacing
            }
            y += row.height + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: nil, height: nil))
            
            if x + size.width > (proposal.width ?? 0) {
                rows.append(currentRow)
                currentRow = Row()
                x = 0
            }
            
            currentRow.elements.append(RowElement(subview: subview, width: size.width, height: size.height))
            x += size.width + spacing
        }
        
        if !currentRow.elements.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private struct Row {
        var elements: [RowElement] = []
        var height: CGFloat { elements.map(\.height).max() ?? 0 }
    }
    
    private struct RowElement {
        let subview: LayoutSubview
        let width: CGFloat
        let height: CGFloat
    }
}
