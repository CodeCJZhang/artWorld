//
//  WaterFLayout.m
//  CollectionView
//
//  Created by d2space on 14-2-24.
//  Copyright (c) 2014年 D2space. All rights reserved.
//

#import "WaterFLayout.h"

NSString *const WaterFallSectionHeader = @"WaterFallSectionHeader";
NSString *const WaterFallSectionFooter = @"WaterFallSectionFooter";


@interface WaterFLayout ()

/// The delegate will point to collection view's delegate automatically.
@property (nonatomic, weak) id <WaterFLayoutDelegate> delegate;
/// Array to store height for each column
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// Array of arrays. Each array stores item attributes for each section
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
/// Array to store attributes for all items includes headers, cells, and footers
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// Dictionary to store section headers' attribute
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
/// Dictionary to store section footers' attribute
@property (nonatomic, strong) NSMutableDictionary *footersAttrubite;
/// Array to store union rectangles
@property (nonatomic, strong) NSMutableArray *unionRects;
/// Width for each item
@property (nonatomic, assign) CGFloat itemWidth;
@end

@implementation WaterFLayout
// How many items to be union into a single rectangle
const NSInteger unionSize = 20;

#pragma mark - Public Accessors
- (void)setColumnCount:(NSInteger)columnCount
{
    if (_columnCount != columnCount)
    {
        _columnCount = columnCount;
        [self invalidateLayout];
    }
}

- (void)setMinimumColumnSpacing:(CGFloat)minimumColumnSpacing
{
    if (_minimumColumnSpacing != minimumColumnSpacing)
    {
        _minimumColumnSpacing = minimumColumnSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    if (_minimumInteritemSpacing != minimumInteritemSpacing)
    {
        _minimumInteritemSpacing = minimumInteritemSpacing;
        [self invalidateLayout];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
    if (_headerHeight != headerHeight)
    {
        _headerHeight = headerHeight;
        [self invalidateLayout];
    }
}

- (void)setFooterHeight:(CGFloat)footerHeight
{
    if (_footerHeight != footerHeight)
    {
        _footerHeight = footerHeight;
        [self invalidateLayout];
    }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset))
    {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

#pragma mark - Private Accessors
- (NSMutableDictionary *)headersAttribute
{
    if (!_headersAttribute)
    {
        _headersAttribute = [NSMutableDictionary dictionary];
    }
    return _headersAttribute;
}

- (NSMutableDictionary *)footersAttrubite
{
    if (!_footersAttrubite)
    {
        _footersAttrubite = [NSMutableDictionary dictionary];
    }
    return _footersAttrubite;
}

- (NSMutableArray *)unionRects
{
    if (!_unionRects)
    {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

- (NSMutableArray *)columnHeights
{
    if (!_columnHeights)
    {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (NSMutableArray *)allItemAttributes
{
    if (!_allItemAttributes)
    {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableArray *)sectionItemAttributes
{
    if (!_sectionItemAttributes)
    {
        _sectionItemAttributes = [NSMutableArray array];
    }
    return _sectionItemAttributes;
}

#pragma mark - Init
- (void)commonInit
{
    _columnCount = 2;
    _minimumColumnSpacing = 10;
    _minimumInteritemSpacing = 10;
    _headerHeight = 0;
    _footerHeight = 0;
    _sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
}

- (id)init
{
    if (self = [super init])
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

#pragma mark - Methods to Override
- (void)prepareLayout
{
    [super prepareLayout];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0)
    {
        return;
    }
    
    self.delegate = (id <WaterFLayoutDelegate> )self.collectionView.delegate;
//    NSAssert([self.delegate conformsToProtocol:@protocol(WaterFLayoutDelegate)], @"UICollectionView's delegate should conform to WaterFLayoutDelegate protocol");
//    NSAssert(self.columnCount > 0, @"UICollectionViewWaterfallLayout's columnCount should be greater than 0");
    // Initialize variables
    NSInteger idx = 0;
    CGFloat width = self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right;
    
    self.itemWidth = floorf((width - (self.columnCount - 1) * self.minimumColumnSpacing) / self.columnCount);
    
    [self.headersAttribute removeAllObjects];
    [self.footersAttrubite removeAllObjects];
    [self.unionRects removeAllObjects];
    [self.columnHeights removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    
    for (idx = 0; idx < self.columnCount; idx++)
    {
        [self.columnHeights addObject:@(0)];
    }
    
    // Create attributes
    CGFloat top = 0;
    UICollectionViewLayoutAttributes *attributes;
    
    for (NSInteger section = 0; section < numberOfSections; ++section)
    {
        /*
         * 1. Section header
         */
        CGFloat headerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)])
        {
            headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
        }
        else
        {
            headerHeight = self.headerHeight;
        }
        
        if (headerHeight > 0)
        {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:WaterFallSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(0, top, self.collectionView.frame.size.width, headerHeight);
            
            self.headersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame);
        }
        
        top += self.sectionInset.top;
        for (idx = 0; idx < self.columnCount; idx++)
        {
            self.columnHeights[idx] = @(top);
        }
        
        /*
         * 2. Section items
         */
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        
        // Item will be put into shortest column.
        for (idx = 0; idx < itemCount; idx++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            CGFloat itemHeight = floorf(itemSize.height * self.itemWidth / itemSize.width);
            NSUInteger columnIndex = [self shortestColumnIndex];
            CGFloat xOffset = self.sectionInset.left + (self.itemWidth + self.minimumColumnSpacing) * columnIndex;
            CGFloat yOffset = [self.columnHeights[columnIndex] floatValue];
            
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(xOffset, yOffset, self.itemWidth, itemHeight);
            [itemAttributes addObject:attributes];
            [self.allItemAttributes addObject:attributes];
            self.columnHeights[columnIndex] = @(CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing);
        }
        
        [self.sectionItemAttributes addObject:itemAttributes];
        
        /*
         * Section footer
         */
        CGFloat footerHeight;
        NSUInteger columnIndex = [self longestColumnIndex];
        top = [self.columnHeights[columnIndex] floatValue] - self.minimumInteritemSpacing + self.sectionInset.bottom;
        
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)])
        {
            footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
        }
        else
        {
            footerHeight = self.footerHeight;
        }
        
        if (footerHeight > 0)
        {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:WaterFallSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(0, top, self.collectionView.frame.size.width, footerHeight);
            
            self.footersAttrubite[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame);
        }
        
        for (idx = 0; idx < self.columnCount; idx++)
        {
            self.columnHeights[idx] = @(top);
        }
    } // end of for (NSInteger section = 0; section < numberOfSections; ++section)
    
    // Build union rects
    idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts)
    {
        CGRect rect1 = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        idx = MIN(idx + unionSize, itemCounts) - 1;
        CGRect rect2 = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        [self.unionRects addObject:[NSValue valueWithCGRect:CGRectUnion(rect1, rect2)]];
        idx++;
    }
}

- (CGSize)collectionViewContentSize
{
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0)
    {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = [self.columnHeights[0] floatValue];
    
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    if (path.section >= [self.sectionItemAttributes count])
    {
        return nil;
    }
    if (path.item >= [self.sectionItemAttributes[path.section] count])
    {
        return nil;
    }
    return (self.sectionItemAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([kind isEqualToString:WaterFallSectionHeader])
    {
        attribute = self.headersAttribute[@(indexPath.section)];
    } else if ([kind isEqualToString:WaterFallSectionFooter])
    {
        attribute = self.footersAttrubite[@(indexPath.section)];
    }
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < self.unionRects.count; i++)
    {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue]))
        {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--)
    {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue]))
        {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++)
    {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame))
        {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds) ||
        CGRectGetHeight(newBounds) != CGRectGetHeight(oldBounds))
    {
        return YES;
    }
    return NO;
}

#pragma mark - Private Methods

/**
 *  Find the shortest column.
 *
 *  @return index for the shortest column
 */
- (NSUInteger)shortestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight)
        {
            shortestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

/**
 *  Find the longest column.
 *
 *  @return index for the longest column
 */
- (NSUInteger)longestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
        CGFloat height = [obj floatValue];
        if (height > longestHeight)
        {
            longestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}
@end
