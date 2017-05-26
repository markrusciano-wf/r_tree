/*
 * Copyright 2015 Workiva Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of r_tree;

class LeafNode extends Node {
  List<RTreeDatum> _items = [];

  LeafNode(int branchFactor) : super(branchFactor);

  @override
  List<RTreeDatum> get children => _items;

  @override
  Node createNewNode() {
    return new LeafNode(branchFactor);
  }

  @override
  Iterable<RTreeDatum> search(Rectangle searchRect, RTreeTest test) {
    return _items
        .where((RTreeDatum item) => item.overlaps(searchRect) && test(item));
  }

  @override
  Node insert(RTreeDatum item) {
    addChild(item);
    return splitIfNecessary();
  }

  @override
  void remove(RTreeDatum item) {
    removeChild(item);
  }

  @override
  void clearChildren() {
    _items = [];
    _minimumBoundingRect = null;
  }
}
